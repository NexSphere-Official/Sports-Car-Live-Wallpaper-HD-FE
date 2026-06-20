import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/app_open_ad_manager.dart';

/// Shows a cold-start app-open ad at the end of the splash, if one is ready.
/// No-op (returns false) when app-open ads weren't started (ads disabled or
/// consent denied) or on_cold_start is off.
class ShowColdStartAppOpenAdUseCase {
  final AppOpenAdManager _appOpenAdManager;

  ShowColdStartAppOpenAdUseCase(this._appOpenAdManager);

  Future<Either<AdsFailure, bool>> execute() =>
      _appOpenAdManager.showOnColdStart();
}
