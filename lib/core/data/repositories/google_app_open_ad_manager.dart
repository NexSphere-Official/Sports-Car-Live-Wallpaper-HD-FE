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
  DateTime? _loadStartedAt;
  bool _suppressNextResume = false;
  bool _listening = false;
  bool _enabled = false;
  bool _isLoading = false;
  Completer<void>? _loadWaiter;

  @override
  Future<Either<AdsFailure, Unit>> start(AppOpenAdConfig config) async {
    try {
      _config = config;
      _enabled = true;
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
    _suppressNextResume = true;
    return right(unit);
  }

  @override
  Future<Either<AdsFailure, bool>> showOnColdStart() async {
    final config = _config;
    if (!_enabled || config == null || !config.onColdStart) return right(false);

    // Wait for the in-flight preload only while one is actually loading, and
    // only for the remaining load budget — never extend the splash otherwise.
    if (!_isAvailable && _isLoading) {
      final deadline =
          (_loadStartedAt ?? DateTime.now()).add(config.loadTimeout);
      final remaining = deadline.difference(DateTime.now());
      if (remaining > Duration.zero) {
        await (_loadWaiter ??= Completer<void>()).future.timeout(
          remaining,
          onTimeout: () {},
        );
      }
    }

    if (!_isAvailable) {
      // Nothing ready — make sure a fresh ad is queued for later, but don't
      // block the splash any further.
      _loadAd();
      return right(false);
    }

    // Keep the ad over the splash: resolve only once it's dismissed so the
    // caller can hand off to home afterwards.
    await _show();
    return right(true);
  }

  void _onAppStateChanged(AppState state) {
    if (state != AppState.foreground) return;
    final config = _config;
    if (!_enabled || config == null || !config.onResume) return;

    // One-shot suppression (e.g. returning from an external system screen).
    if (_suppressNextResume) {
      _suppressNextResume = false;
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
    _loadStartedAt = DateTime.now();

    // Reset loading state if the SDK callback never fires, so future loads
    // aren't permanently blocked.
    var settled = false;
    final timer = Timer(config.loadTimeout, () {
      if (settled) return;
      settled = true;
      _isLoading = false;
      _completeWaiter();
    });

    AppOpenAd.load(
      adUnitId: config.adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          timer.cancel();
          settled = true;
          _isLoading = false;
          // Disabled meanwhile, or we already hold an ad (late duplicate) →
          // discard rather than leak/show without consent.
          if (!_enabled || _ad != null) {
            ad.dispose();
            _completeWaiter();
            return;
          }
          _ad = ad;
          _loadedAt = DateTime.now();
          _completeWaiter();
        },
        onAdFailedToLoad: (error) {
          timer.cancel();
          settled = true;
          _isLoading = false;
          _ad = null;
          _loadedAt = null;
          _completeWaiter();
        },
      ),
    );
  }

  void _completeWaiter() {
    final waiter = _loadWaiter;
    if (waiter != null && !waiter.isCompleted) waiter.complete();
    _loadWaiter = null;
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
