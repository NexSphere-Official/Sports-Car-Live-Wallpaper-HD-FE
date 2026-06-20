import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/failures/ads_failure.dart';
import '../../domain/repositories/ads_service.dart';
import 'full_screen_ad_guard.dart';

/// [AdsService] backed by the Google Mobile Ads SDK. Full-screen ads are loaded
/// on demand and shown once ready. The shared [FullScreenAdGuard] prevents two
/// full-screen ads (incl. app-open) from overlapping and powers the cooldown.
class GoogleMobileAdsService implements AdsService {
  GoogleMobileAdsService(this._guard);

  final FullScreenAdGuard _guard;

  /// Upper bound on a full-screen ad load so the apply/unlock flow never hangs
  /// on a stalled request. A late load that arrives after this is discarded.
  static const _loadTimeout = Duration(seconds: 12);

  Future<Either<AdsFailure, Unit>>? _initialization;

  /// A rewarded ad loaded ahead of time, ready for the next [showRewarded].
  RewardedAd? _preloadedRewarded;
  bool _isPreloadingRewarded = false;

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

  @override
  Future<Either<AdsFailure, Unit>> showInterstitial(
    String adUnitId, {
    Duration cooldown = Duration.zero,
  }) async {
    // Skip (but let the caller proceed) when another ad is up or we're inside
    // the cooldown window.
    if (_guard.isShowing || _guard.withinCooldown(cooldown)) {
      return right(unit);
    }

    final completer = Completer<Either<AdsFailure, Unit>>();
    var abandoned = false;
    final timer = Timer(_loadTimeout, () {
      abandoned = true;
      // Proceed without the ad rather than block the apply flow.
      if (!completer.isCompleted) completer.complete(right(unit));
    });

    unawaited(
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (abandoned) {
              ad.dispose(); // arrived after the timeout — never show it
              return;
            }
            timer.cancel();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (_) => _guard.markShown(),
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _guard.markDismissed();
                if (!completer.isCompleted) completer.complete(right(unit));
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _guard.markDismissed();
                if (!completer.isCompleted) {
                  completer.complete(left(AdsFailure.unknown(error)));
                }
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {
            if (abandoned) return;
            timer.cancel();
            if (!completer.isCompleted) {
              completer.complete(left(AdsFailure.unknown(error)));
            }
          },
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<Either<AdsFailure, Unit>> preloadRewarded(String adUnitId) {
    if (_preloadedRewarded != null || _isPreloadingRewarded) {
      return Future.value(right(unit));
    }
    _isPreloadingRewarded = true;

    final completer = Completer<Either<AdsFailure, Unit>>();
    unawaited(
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _isPreloadingRewarded = false;
            _preloadedRewarded = ad;
            if (!completer.isCompleted) completer.complete(right(unit));
          },
          onAdFailedToLoad: (error) {
            _isPreloadingRewarded = false;
            _preloadedRewarded = null;
            if (!completer.isCompleted) {
              completer.complete(left(AdsFailure.unknown(error)));
            }
          },
        ),
      ),
    );
    return completer.future;
  }

  @override
  Future<Either<AdsFailure, bool>> showRewarded(String adUnitId) async {
    // Don't stack on another full-screen ad; treat as "not earned".
    if (_guard.isShowing) return right(false);

    // Fast path: a preloaded ad is ready — show it immediately, no wait.
    final preloaded = _preloadedRewarded;
    if (preloaded != null) {
      _preloadedRewarded = null;
      return _showRewardedAd(preloaded);
    }

    final completer = Completer<Either<AdsFailure, bool>>();
    var abandoned = false;
    final timer = Timer(_loadTimeout, () {
      abandoned = true;
      // Surface a failure so the caller shows "couldn't load, try again"
      // rather than the "watch the full ad" (not-earned) message.
      if (!completer.isCompleted) {
        completer.complete(left(const AdsFailure.unknown('rewarded load timed out')));
      }
    });

    unawaited(
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (abandoned) {
              ad.dispose(); // arrived after the timeout — never show it
              return;
            }
            timer.cancel();
            unawaited(
              _showRewardedAd(ad).then((result) {
                if (!completer.isCompleted) completer.complete(result);
              }),
            );
          },
          onAdFailedToLoad: (error) {
            if (abandoned) return;
            timer.cancel();
            if (!completer.isCompleted) {
              completer.complete(left(AdsFailure.unknown(error)));
            }
          },
        ),
      ),
    );
    return completer.future;
  }

  /// Wires the full-screen callbacks and shows a ready rewarded [ad], resolving
  /// once it's dismissed with whether the reward was earned.
  Future<Either<AdsFailure, bool>> _showRewardedAd(RewardedAd ad) {
    final completer = Completer<Either<AdsFailure, bool>>();
    var earnedReward = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _guard.markShown(),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _guard.markDismissed();
        if (!completer.isCompleted) completer.complete(right(earnedReward));
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _guard.markDismissed();
        if (!completer.isCompleted) {
          completer.complete(left(AdsFailure.unknown(error)));
        }
      },
    );
    ad.show(onUserEarnedReward: (_, _) => earnedReward = true);
    return completer.future;
  }
}
