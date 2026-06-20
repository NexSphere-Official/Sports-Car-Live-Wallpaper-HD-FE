import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../stores/app_config/app_config_store.dart';

/// Shows the interstitial that precedes applying an interstitial-type wallpaper.
/// No-op (success) when interstitials are disabled. The cooldown/skip handling
/// lives in [AdsService]; callers proceed with the apply flow regardless.
class ShowApplyInterstitialUseCase {
  final AdsService _adsService;
  final AppConfigStore _appConfigStore;

  ShowApplyInterstitialUseCase(this._adsService, this._appConfigStore);

  Future<Either<AdsFailure, Unit>> execute() {
    final config = _appConfigStore.config.ads.interstitial;
    if (!config.isUsable) return Future.value(right(unit));
    return _adsService.showInterstitial(
      config.adUnitId,
      cooldown: config.cooldown,
    );
  }
}
