import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/app_open_ad_manager.dart';

/// Suppresses the next foreground app-open ad — used before launching an
/// external system screen (e.g. the live-wallpaper preview) that backgrounds
/// the app, so the resume doesn't trigger an app-open over the returning UI.
class SuppressNextAppOpenAdUseCase {
  final AppOpenAdManager _appOpenAdManager;

  SuppressNextAppOpenAdUseCase(this._appOpenAdManager);

  Future<Either<AdsFailure, Unit>> execute() =>
      _appOpenAdManager.suppressNextResume();
}
