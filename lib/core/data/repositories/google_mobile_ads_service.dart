import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/failures/ads_failure.dart';
import '../../domain/repositories/ads_service.dart';
import 'full_screen_ad_guard.dart';

/// [AdsService] backed by the Google Mobile Ads SDK. Full-screen ads are loaded
/// (with a timeout) and cached for instant display. The shared
/// [FullScreenAdGuard] prevents two full-screen ads (incl. app-open) from
/// overlapping and powers the cooldown.
class GoogleMobileAdsService implements AdsService {
  GoogleMobileAdsService(this._guard);

  final FullScreenAdGuard _guard;

  /// Upper bound on a full-screen ad load so flows never hang on a stalled
  /// request, and so a preload can't get stuck. A late load is discarded.
  static const _loadTimeout = Duration(seconds: 12);

  Future<Either<AdsFailure, Unit>>? _initialization;

  InterstitialAd? _preloadedInterstitial;
  Completer<void>? _interstitialPreload;

  RewardedAd? _preloadedRewarded;
  Completer<void>? _rewardedPreload;

  @override
  Future<Either<AdsFailure, Unit>> initialize() {
    return _initialization ??= _initialize();
  }

  Future<Either<AdsFailure, Unit>> _initialize() async {
    try {
      await MobileAds.instance.initialize();
      return right(unit);
    } catch (ex) {
      _initialization = null;
      return left(AdsFailure.initialization(ex));
    }
  }

  // --- Interstitial ---------------------------------------------------------

  @override
  Future<Either<AdsFailure, Unit>> preloadInterstitial(String adUnitId) async {
    if (_preloadedInterstitial != null || _interstitialPreload != null) {
      return right(unit);
    }
    final completer = Completer<void>();
    _interstitialPreload = completer;
    _preloadedInterstitial = await _loadInterstitialOnce(adUnitId);
    _interstitialPreload = null;
    if (!completer.isCompleted) completer.complete();
    return right(unit);
  }

  @override
  Future<Either<AdsFailure, Unit>> showInterstitial(
    String adUnitId, {
    Duration cooldown = Duration.zero,
  }) async {
    if (_skipFullScreen(cooldown)) return right(unit);

    // Reuse an in-flight preload rather than starting a second load.
    final inFlight = _interstitialPreload;
    if (_preloadedInterstitial == null && inFlight != null) {
      await inFlight.future;
    }

    var ad = _preloadedInterstitial;
    _preloadedInterstitial = null;
    ad ??= await _loadInterstitialOnce(adUnitId);
    if (ad == null) return right(unit); // load failed/timed out — proceed

    // Re-check the guard now that loading is done (another ad may have appeared).
    if (_skipFullScreen(cooldown)) {
      ad.dispose();
      return right(unit);
    }
    return _showInterstitialAd(ad);
  }

  @override
  Future<Either<AdsFailure, Unit>> showInterstitialIfReady(
    String adUnitId, {
    Duration cooldown = Duration.zero,
  }) async {
    if (_skipFullScreen(cooldown)) return right(unit);
    final ad = _preloadedInterstitial;
    if (ad == null) return right(unit); // not ready — skip, no late pop
    _preloadedInterstitial = null;
    return _showInterstitialAd(ad);
  }

  Future<Either<AdsFailure, Unit>> _showInterstitialAd(InterstitialAd ad) {
    // Atomically claim the slot right before showing; if another placement won
    // the race, skip (caller proceeds).
    if (!_guard.reserve()) {
      ad.dispose();
      return Future.value(right(unit));
    }
    final completer = Completer<Either<AdsFailure, Unit>>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _guard.markShown(),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _guard.release();
        if (!completer.isCompleted) completer.complete(right(unit));
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _guard.release();
        if (!completer.isCompleted) {
          completer.complete(left(AdsFailure.unknown(error)));
        }
      },
    );
    ad.show();
    return completer.future;
  }

  Future<InterstitialAd?> _loadInterstitialOnce(String adUnitId) {
    final completer = Completer<InterstitialAd?>();
    final timer = Timer(_loadTimeout, () {
      if (!completer.isCompleted) completer.complete(null);
    });
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          timer.cancel();
          if (completer.isCompleted) {
            ad.dispose(); // arrived after timeout — discard
            return;
          }
          completer.complete(ad);
        },
        onAdFailedToLoad: (_) {
          timer.cancel();
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    return completer.future;
  }

  // --- Rewarded -------------------------------------------------------------

  @override
  Future<Either<AdsFailure, Unit>> preloadRewarded(String adUnitId) async {
    if (_preloadedRewarded != null || _rewardedPreload != null) {
      return right(unit);
    }
    final completer = Completer<void>();
    _rewardedPreload = completer;
    _preloadedRewarded = await _loadRewardedOnce(adUnitId);
    _rewardedPreload = null;
    if (!completer.isCompleted) completer.complete();
    return right(unit);
  }

  @override
  Future<Either<AdsFailure, bool>> showRewarded(String adUnitId) async {
    // Don't stack on another full-screen ad; treat as "not earned".
    if (_guard.isShowing) return right(false);

    // Reuse an in-flight preload rather than starting a second load.
    final inFlight = _rewardedPreload;
    if (_preloadedRewarded == null && inFlight != null) {
      await inFlight.future;
    }

    var ad = _preloadedRewarded;
    _preloadedRewarded = null;
    ad ??= await _loadRewardedOnce(adUnitId);
    if (ad == null) {
      return left(const AdsFailure.unknown('rewarded ad unavailable'));
    }

    // Re-check the guard now that loading is done.
    if (_guard.isShowing) {
      ad.dispose();
      return right(false);
    }
    return _showRewardedAd(ad);
  }

  Future<Either<AdsFailure, bool>> _showRewardedAd(RewardedAd ad) {
    // Atomically claim the slot right before showing; if another placement won
    // the race, skip (treat as not earned).
    if (!_guard.reserve()) {
      ad.dispose();
      return Future.value(right(false));
    }
    final completer = Completer<Either<AdsFailure, bool>>();
    var earnedReward = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _guard.markShown(),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _guard.release();
        if (!completer.isCompleted) completer.complete(right(earnedReward));
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _guard.release();
        if (!completer.isCompleted) {
          completer.complete(left(AdsFailure.unknown(error)));
        }
      },
    );
    ad.show(onUserEarnedReward: (_, _) => earnedReward = true);
    return completer.future;
  }

  Future<RewardedAd?> _loadRewardedOnce(String adUnitId) {
    final completer = Completer<RewardedAd?>();
    final timer = Timer(_loadTimeout, () {
      if (!completer.isCompleted) completer.complete(null);
    });
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          timer.cancel();
          if (completer.isCompleted) {
            ad.dispose(); // arrived after timeout — discard
            return;
          }
          completer.complete(ad);
        },
        onAdFailedToLoad: (_) {
          timer.cancel();
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    return completer.future;
  }

  /// Whether a full-screen ad should be skipped: another is showing, or we're
  /// within the cooldown window.
  bool _skipFullScreen(Duration cooldown) =>
      _guard.isShowing || _guard.withinCooldown(cooldown);
}
