import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';

/// Shows an interstitial when navigating back from the Saved page. No-op
/// (success) when ads aren't ready, interstitials are disabled, or the
/// `on_back_from_saved` flag is off. The shared cooldown/guard in [AdsService]
/// still applies, so this won't stack on a recent full-screen ad.
class ShowBackInterstitialUseCase {
  final AdsService _adsService;
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;

  ShowBackInterstitialUseCase(
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
    return _adsService.showInterstitial(
      config.adUnitId,
      cooldown: config.cooldown,
    );
  }
}
