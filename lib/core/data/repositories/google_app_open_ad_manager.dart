import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/failures/ads_failure.dart';
import '../../domain/models/ads_config.dart';
import '../../domain/repositories/app_open_ad_manager.dart';
import 'full_screen_ad_guard.dart';

/// [AppOpenAdManager] backed by the Google Mobile Ads SDK, following Google's
/// recommended pattern: preload, track a 4-hour cache expiry, reload after each
/// dismiss/failure, and show on foreground via [AppStateEventNotifier]. Shares
/// the [FullScreenAdGuard] so it never overlaps an interstitial/rewarded ad.
///
/// App-open is the one format that must stay preloaded — there is no moment of
/// user intent to load against, only the instant they return to the app. The
/// preload starts during the splash so launch's dead time is put to use, but
/// the splash is never held for it and the ad is never drawn over it: a
/// cold-start ad is shown once the app itself is on screen, and only if one was
/// already in hand by then. A resume additionally requires a real absence
/// ([AppOpenAdConfig.minBackgroundDuration]) rather than a momentary flick out
/// to a system sheet.
///
/// [_enabled] gates all activity so it can be turned off the moment consent is
/// revoked (and back on when re-granted) without waiting for a relaunch.
class GoogleAppOpenAdManager implements AppOpenAdManager {
  GoogleAppOpenAdManager(this._guard);

  final FullScreenAdGuard _guard;

  /// App-open ad references time out after four hours (per AdMob).
  static const _maxCacheDuration = Duration(hours: 4);

  AppOpenAdConfig? _config;
  AppOpenAd? _ad;
  DateTime? _loadedAt;
  DateTime? _backgroundedAt;

  /// One-shot resume suppression, with a deadline. Previously an unbounded
  /// bool: if the action that set it never actually backgrounded the app (a
  /// failed share/preview launch), it silently swallowed some unrelated resume
  /// ad much later.
  DateTime? _suppressResumeUntil;

  bool _listening = false;
  bool _enabled = false;
  bool _isLoading = false;

  /// Until the cold-start decision has been made, foreground events are
  /// ignored: the launch foreground itself would otherwise fire a resume ad
  /// over the splash and consume the ad the cold-start path is waiting for.
  /// Starts settled, so a mid-session start (consent granted late) serves
  /// resume ads right away rather than waiting for a cold start that already
  /// went by.
  bool _coldStartSettled = true;


  @override
  Future<Either<AdsFailure, Unit>> start(
    AppOpenAdConfig config, {
    required bool expectColdStart,
  }) async {
    try {
      _config = config;
      _enabled = true;
      if (expectColdStart) _coldStartSettled = false;
      _loadAd();
      if (!_listening) {
        _listening = true;
        AppStateEventNotifier.startListening();
        AppStateEventNotifier.appStateStream.listen(_onAppStateChanged);
      }
      return right(unit);
    } catch (ex) {
      return left(AdsFailure.unknown(ex));
    }
  }

  @override
  Future<Either<AdsFailure, Unit>> stop() async {
    _enabled = false;
    _disposeAd();
    return right(unit);
  }

  @override
  Future<Either<AdsFailure, Unit>> suppressNextResume() async {
    final config = _config;
    _suppressResumeUntil = DateTime.now().add(
      config?.suppressResumeWindow ?? const Duration(minutes: 5),
    );
    return right(unit);
  }

  @override
  Future<Either<AdsFailure, bool>> showOnColdStart() async {
    final config = _config;
    _coldStartSettled = true;
    if (!_enabled || config == null || !config.onColdStart) {
      return right(false);
    }

    // Never wait on a load here. The preload that started at launch either
    // filled while the splash played or it didn't; if it didn't, the ad stays
    // queued for the next resume rather than becoming a delay the user sits
    // through.
    if (!_isAvailable) {
      if (!_isLoading) _loadAd();
      return right(false);
    }

    await _show();
    return right(true);
  }

  void _onAppStateChanged(AppState state) {
    if (state == AppState.background) {
      _backgroundedAt = DateTime.now();
      return;
    }
    if (state != AppState.foreground) return;

    final config = _config;
    if (!_enabled || config == null || !config.onResume) return;

    // The launch foreground is not a resume — let showOnColdStart own it.
    if (!_coldStartSettled) return;

    // One-shot suppression (e.g. returning from an external system screen).
    final suppressUntil = _suppressResumeUntil;
    if (suppressUntil != null) {
      _suppressResumeUntil = null;
      if (DateTime.now().isBefore(suppressUntil)) return;
    }

    // Require a real absence. A share sheet, permission dialog or wallpaper
    // preview that the user dismisses immediately is not a return to the app,
    // and interrupting that with a full-screen ad is exactly the pattern
    // AdMob's app-open policy warns against.
    // A null timestamp means we never saw the matching background event, so the
    // absence is unknown rather than short — fall through instead of dropping
    // the placement on a missed event.
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt != null &&
        DateTime.now().difference(backgroundedAt) <
            config.minBackgroundDuration) {
      return;
    }

    if (_guard.isShowing) return;

    // Honour the cooldown against the last full-screen ad of ANY kind (shared
    // guard), so an app-open never stacks right after an interstitial/rewarded.
    if (_guard.withinCooldown(config.resumeCooldown)) return;

    // Expired or never loaded: drop any stale ad and (re)load for next time
    // instead of showing a stale/absent ad.
    if (!_isAvailable) {
      _disposeAd();
      _loadAd();
      return;
    }

    _show();
  }

  bool get _isAvailable {
    if (_ad == null) return false;
    final loadedAt = _loadedAt;
    return loadedAt != null &&
        DateTime.now().difference(loadedAt) < _maxCacheDuration;
  }

  void _loadAd() {
    final config = _config;
    if (!_enabled || config == null || config.adUnitId.isEmpty) return;
    if (_isLoading || _isAvailable) return;

    _isLoading = true;

    // Frees the slot so a stalled SDK callback can't wedge loading for the rest
    // of the session. The request itself is left running: if it lands late we
    // still take the ad (see the _ad != null check below, which drops the
    // duplicate if a second attempt filled first) rather than paying for a fill
    // and binning it.
    final timer = Timer(config.loadTimeout, () {
      if (!_isLoading) return;
      _isLoading = false;
    });

    AppOpenAd.load(
      adUnitId: config.adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          timer.cancel();
          _isLoading = false;
          // Disabled meanwhile, or we already hold an ad (late duplicate) →
          // discard rather than leak/show without consent.
          if (!_enabled || _ad != null) {
            ad.dispose();
            return;
          }
          _ad = ad;
          _loadedAt = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          timer.cancel();
          _isLoading = false;
          _ad = null;
          _loadedAt = null;
        },
      ),
    );
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
    _loadedAt = null;
  }

  /// Shows the loaded ad; resolves once it's dismissed (or fails to show).
  Future<void> _show() {
    final ad = _ad;
    // Atomically claim the shared full-screen slot before showing.
    if (ad == null || !_guard.reserve()) return Future.value();

    // Consume our reference up front; the callbacks hold the local [ad].
    _ad = null;
    _loadedAt = null;
    final dismissed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _guard.markShown(),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _guard.release();
        _loadAd();
        if (!dismissed.isCompleted) dismissed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _guard.release();
        _loadAd();
        if (!dismissed.isCompleted) dismissed.complete();
      },
    );
    ad.show();
    return dismissed.future;
  }
}
