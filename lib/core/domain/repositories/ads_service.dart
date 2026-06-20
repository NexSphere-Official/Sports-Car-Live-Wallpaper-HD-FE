import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';

/// Boundary over the Google Mobile Ads SDK.
abstract class AdsService {
  /// Initialize the underlying ads SDK. Safe to call once consent allows ad
  /// requests. Idempotent on success; a failed attempt can be retried.
  Future<Either<AdsFailure, Unit>> initialize();

  /// Preload an interstitial so a later [showInterstitialIfReady] can display it
  /// instantly. Idempotent — no-op when one is already loaded or loading.
  Future<Either<AdsFailure, Unit>> preloadInterstitial(String adUnitId);

  /// Load (using any preloaded/in-flight ad) and show an interstitial. Resolves
  /// once dismissed.
  ///
  /// Returns `right(unit)` whether the ad was shown OR intentionally skipped
  /// (another full-screen ad is showing, within [cooldown], or load failed) —
  /// callers proceed regardless. Used for user-initiated transitions where a
  /// brief load wait is acceptable.
  Future<Either<AdsFailure, Unit>> showInterstitial(
    String adUnitId, {
    Duration cooldown = Duration.zero,
  });

  /// Show a preloaded interstitial ONLY if one is ready right now — never loads
  /// on demand. Used at transition points (e.g. back navigation) where a late
  /// pop would be disruptive. No-op (`right(unit)`) when none is ready.
  Future<Either<AdsFailure, Unit>> showInterstitialIfReady(
    String adUnitId, {
    Duration cooldown = Duration.zero,
  });

  /// Preload a rewarded ad so a later [showRewarded] can display instantly.
  /// Idempotent — no-op when one is already loaded or loading.
  Future<Either<AdsFailure, Unit>> preloadRewarded(String adUnitId);

  /// Show a rewarded ad — using a preloaded/in-flight one if available,
  /// otherwise loading on demand. Resolves once dismissed with whether the
  /// reward was earned (`right(true)`) or not (`right(false)`); `left` on a
  /// load/show error.
  Future<Either<AdsFailure, bool>> showRewarded(String adUnitId);
}
