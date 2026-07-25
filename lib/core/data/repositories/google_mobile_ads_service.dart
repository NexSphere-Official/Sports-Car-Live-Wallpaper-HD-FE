import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/failures/ads_failure.dart';
import '../../domain/repositories/ads_service.dart';
import 'full_screen_ad_guard.dart';

/// [AdsService] backed by the Google Mobile Ads SDK.
///
/// Full-screen ads are loaded on demand and shown immediately — nothing is
/// cached between placements. That removes the two things that used to burn
/// matched requests without ever producing an impression: ads preloaded for an
/// action the user never took, and cached ads that went stale before anything
/// tried to show them. The trade is a load wait at the point of use, which
/// callers surface with their own busy state.
///
/// The shared [FullScreenAdGuard] prevents two full-screen ads (incl. app-open)
/// from overlapping and powers the cooldown.
class GoogleMobileAdsService implements AdsService {
  GoogleMobileAdsService(this._guard);

  final FullScreenAdGuard _guard;

  /// Upper bound on a full-screen ad load so a flow never hangs on a stalled
  /// request. Deliberately generous: this now runs while the user waits, but
  /// cutting it short only converts a slow fill into a discarded one.
  static const _loadTimeout = Duration(seconds: 12);

  Future<Either<AdsFailure, Unit>>? _initialization;

  /// False once [stop] runs, so an in-flight load can't surface an ad after
  /// consent was withdrawn.
  bool _enabled = false;

  @override
  Future<Either<AdsFailure, Unit>> initialize() async {
    final result = await (_initialization ??= _initialize());
    // Re-arm serving here, not inside _initialize: SDK initialization is
    // memoized, so a re-grant of consent after [stop] returns the cached
    // future and would otherwise never turn requesting back on.
    if (result.isRight()) _enabled = true;
    return result;
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
  Future<Either<AdsFailure, Unit>> stop() async {
    _enabled = false;
    return right(unit);
  }

  // --- Interstitial ---------------------------------------------------------

  @override
  Future<Either<AdsFailure, Unit>> showInterstitial(
    String adUnitId, {
    Duration cooldown = Duration.zero,
  }) async {
    if (_skipFullScreen(cooldown)) return right(unit);

    final ad = await _loadInterstitialOnce(adUnitId);
    if (ad == null) return right(unit); // load failed/timed out — proceed

    // Re-check now that loading is done: another placement may have taken the
    // slot while we waited.
    if (_skipFullScreen(cooldown)) {
      ad.dispose();
      return right(unit);
    }
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
          // Arrived after we stopped waiting, or consent was withdrawn while
          // it was in flight — discard rather than show.
          timer.cancel();
          if (completer.isCompleted || !_enabled) {
            ad.dispose();
            if (!completer.isCompleted) completer.complete(null);
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
  Future<Either<AdsFailure, bool>> showRewarded(String adUnitId) async {
    // Don't stack on another full-screen ad; treat as "not earned".
    if (_guard.isShowing) return right(false);

    final ad = await _loadRewardedOnce(adUnitId);
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
          if (completer.isCompleted || !_enabled) {
            ad.dispose();
            if (!completer.isCompleted) completer.complete(null);
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

  /// Whether a full-screen ad should be skipped: serving is off, another is
  /// showing, or we're within the cooldown window.
  bool _skipFullScreen(Duration cooldown) =>
      !_enabled || _guard.isShowing || _guard.withinCooldown(cooldown);
}
