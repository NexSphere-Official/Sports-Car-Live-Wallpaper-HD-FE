import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';

/// Preloads a rewarded ad for an about-to-be-shown locked wallpaper, so the
/// unlock ad appears instantly when tapped. No-op (success) when ads aren't
/// ready or rewarded ads are not usable.
class PreloadRewardedAdUseCase {
  final AdsService _adsService;
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;

  PreloadRewardedAdUseCase(
    this._adsService,
    this._appConfigStore,
    this._adsStore,
  );

  Future<Either<AdsFailure, Unit>> execute() {
    final rewarded = _appConfigStore.config.ads.rewarded;
    if (!_adsStore.canRequestAds || !rewarded.isUsable) {
      return Future.value(right(unit));
    }
    return _adsService.preloadRewarded(rewarded.adUnitId);
  }
}
