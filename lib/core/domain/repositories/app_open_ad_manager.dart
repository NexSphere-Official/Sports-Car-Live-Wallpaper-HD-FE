import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../models/ads_config.dart';

/// Manages app-open ads: preloads them, shows one on cold start, and shows one
/// each time the app returns to the foreground (subject to config + cooldown).
abstract class AppOpenAdManager {
  /// Begin managing app-open ads with the given [config]: preload an ad and, if
  /// resume ads are enabled, start showing on each foreground. Idempotent —
  /// also used to re-enable after a [stop] (e.g. consent re-granted).
  ///
  /// [expectColdStart] must be true only when the caller will go on to call
  /// [showOnColdStart] — i.e. this is app launch. Foreground events are then
  /// held back until that call resolves, so the launch foreground itself can't
  /// fire a resume ad over the splash and consume the ad the cold-start path is
  /// waiting for. Pass false when starting mid-session (consent granted late,
  /// or re-granted from Settings), where there is no cold start to wait for and
  /// resume ads must work immediately.
  Future<Either<AdsFailure, Unit>> start(
    AppOpenAdConfig config, {
    required bool expectColdStart,
  });

  /// Stop managing app-open ads and drop any cached ad — call when ads can no
  /// longer be requested (e.g. consent revoked). Foreground events are ignored
  /// until [start] is called again.
  Future<Either<AdsFailure, Unit>> stop();

  /// Show a cold-start app-open ad, if one is already loaded. Never waits on a
  /// load, and must be called once the app's first screen is up rather than
  /// while a splash is showing — the ad is not meant to be drawn over launch UI.
  /// Returns whether an ad was shown.
  Future<Either<AdsFailure, bool>> showOnColdStart();

  /// Skip the next foreground app-open — call before launching an external
  /// system screen (e.g. the live-wallpaper preview) that backgrounds the app.
  Future<Either<AdsFailure, Unit>> suppressNextResume();
}
