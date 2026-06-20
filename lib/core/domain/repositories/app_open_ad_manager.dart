import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../models/ads_config.dart';

/// Manages app-open ads: preloads them, shows one on cold start, and shows one
/// each time the app returns to the foreground (subject to config + cooldown).
abstract class AppOpenAdManager {
  /// Begin managing app-open ads with the given [config]: preload an ad and, if
  /// resume ads are enabled, start showing on each foreground. Idempotent —
  /// also used to re-enable after a [stop] (e.g. consent re-granted).
  Future<Either<AdsFailure, Unit>> start(AppOpenAdConfig config);

  /// Stop managing app-open ads and drop any cached ad — call when ads can no
  /// longer be requested (e.g. consent revoked). Foreground events are ignored
  /// until [start] is called again.
  Future<Either<AdsFailure, Unit>> stop();

  /// Show a cold-start app-open ad, waiting for the preload to finish within the
  /// configured load budget. Returns whether an ad was shown.
  Future<Either<AdsFailure, bool>> showOnColdStart();

  /// Skip the next foreground app-open — call before launching an external
  /// system screen (e.g. the live-wallpaper preview) that backgrounds the app.
  Future<Either<AdsFailure, Unit>> suppressNextResume();
}
