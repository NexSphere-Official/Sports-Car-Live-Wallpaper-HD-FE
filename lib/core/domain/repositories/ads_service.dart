import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';

/// Boundary over the Google Mobile Ads SDK.
///
/// Full-screen ads are loaded strictly on demand — at the moment the user's
/// action calls for one — and never speculatively. Preloading ahead of intent
/// filled far more requests than it ever displayed, which is what dragged the
/// reported show rate down; the cost of loading late is a brief wait the
/// calling flow already surfaces.
abstract class AdsService {
  /// Initialize the underlying ads SDK. Safe to call once consent allows ad
  /// requests. Idempotent on success; a failed attempt can be retried.
  Future<Either<AdsFailure, Unit>> initialize();

  /// Load and show an interstitial. Resolves once dismissed.
  ///
  /// Returns `right(unit)` whether the ad was shown OR intentionally skipped
  /// (another full-screen ad is showing, within [cooldown], or the load
  /// failed) — callers proceed regardless.
  Future<Either<AdsFailure, Unit>> showInterstitial(
    String adUnitId, {
    Duration cooldown = Duration.zero,
  });

  /// Load and show a rewarded ad. Resolves once dismissed with whether the
  /// reward was earned (`right(true)`) or not (`right(false)`); `left` on a
  /// load/show error.
  Future<Either<AdsFailure, bool>> showRewarded(String adUnitId);

  /// Stop serving: any in-flight load is abandoned and a late arrival is
  /// discarded rather than shown. Called when consent is withdrawn or ads are
  /// switched off mid-session. [initialize] re-enables.
  Future<Either<AdsFailure, Unit>> stop();
}
