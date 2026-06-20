import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';

/// Preloads the interstitial shown when leaving the Saved page, so it's ready to
/// display during the back transition. No-op (success) when ads aren't ready,
/// interstitials are disabled, or the `on_back_from_saved` flag is off.
class PreloadSavedInterstitialUseCase {
  final AdsService _adsService;
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;

  PreloadSavedInterstitialUseCase(
    this._adsService,
    this._appConfigStore,
    this._adsStore,
  );

  Future<Either<AdsFailure, Unit>> execute() {
    final config = _appConfigStore.config.ads.interstitial;
    if (!_adsStore.canRequestAds ||
        !config.isUsable ||
        !config.onBackFromSaved) {
      return Future.value(right(unit));
    }
    return _adsService.preloadInterstitial(config.adUnitId);
  }
}
