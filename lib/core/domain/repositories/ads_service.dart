import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';

/// Boundary over the Google Mobile Ads SDK.
abstract class AdsService {
  /// Initialize the underlying ads SDK. Safe to call once consent allows ad
  /// requests. Idempotent on success; a failed attempt can be retried.
  Future<Either<AdsFailure, Unit>> initialize();

  /// Load and show an interstitial. Resolves once the ad is dismissed.
  ///
  /// Returns `right(unit)` whether the ad was shown OR intentionally skipped
  /// (another full-screen ad is showing, or within [cooldown] of the last one)
  /// — callers should proceed with their flow regardless. Returns `left` only
  /// on a genuine load/show error.
  Future<Either<AdsFailure, Unit>> showInterstitial(
    String adUnitId, {
    Duration cooldown = Duration.zero,
  });

  /// Preload a rewarded ad so a later [showRewarded] can display instantly.
  /// Idempotent — no-op when one is already loaded or loading. Resolves
  /// `right(unit)` when ready (or already pending), `left` on load error.
  Future<Either<AdsFailure, Unit>> preloadRewarded(String adUnitId);

  /// Show a rewarded ad — using a preloaded one if available, otherwise loading
  /// on demand. Resolves once dismissed with whether the reward was earned
  /// (`right(true)`) or not (`right(false)`); `left` on a load/show error.
  Future<Either<AdsFailure, bool>> showRewarded(String adUnitId);
}
