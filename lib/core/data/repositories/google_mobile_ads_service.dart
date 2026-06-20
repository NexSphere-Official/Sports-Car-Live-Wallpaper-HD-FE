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

  Future<Either<AdsFailure, Unit>>? _initialization;

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
    unawaited(
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
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

    final completer = Completer<Either<AdsFailure, bool>>();
    var earnedReward = false;
    unawaited(
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (_) => _guard.markShown(),
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _guard.markDismissed();
                if (!completer.isCompleted) {
                  completer.complete(right(earnedReward));
                }
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
          },
          onAdFailedToLoad: (error) {
            if (!completer.isCompleted) {
              completer.complete(left(AdsFailure.unknown(error)));
            }
          },
        ),
      ),
    );
    return completer.future;
  }
}
