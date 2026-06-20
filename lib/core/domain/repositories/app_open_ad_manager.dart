import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../models/ads_config.dart';

/// Manages app-open ads: preloads them, shows one on cold start, and shows one
/// each time the app returns to the foreground (subject to config + cooldown).
abstract class AppOpenAdManager {
  /// Begin managing app-open ads with the given [config]: preload an ad and, if
  /// resume ads are enabled, start showing on each foreground.
  Future<Either<AdsFailure, Unit>> start(AppOpenAdConfig config);

  /// Show a cold-start app-open ad, waiting for the preload to finish within the
  /// configured load budget. Returns whether an ad was shown.
  Future<Either<AdsFailure, bool>> showOnColdStart();

  /// Skip the next foreground app-open — call before launching an external
  /// system screen (e.g. the live-wallpaper preview) that backgrounds the app.
  Future<Either<AdsFailure, Unit>> suppressNextResume();
}
