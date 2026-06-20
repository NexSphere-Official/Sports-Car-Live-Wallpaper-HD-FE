import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';

/// Shows an interstitial when navigating back from the Saved page — but only if
/// one was already preloaded (see [PreloadSavedInterstitialUseCase]), so it
/// appears during the transition rather than popping seconds later over the
/// previous screen. No-op (success) when ads aren't ready, interstitials are
/// disabled, the `on_back_from_saved` flag is off, or none is ready. The shared
/// cooldown/guard in [AdsService] still applies.
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
    return _adsService.showInterstitialIfReady(
      config.adUnitId,
      cooldown: config.cooldown,
    );
  }
}
