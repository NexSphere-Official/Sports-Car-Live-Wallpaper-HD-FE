import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ad_policy_repository.dart';
import '../repositories/ads_service.dart';
import '../stores/app_config/app_config_store.dart';

/// Shows a rewarded ad to unlock a locked wallpaper. On a earned reward the
/// unlock is persisted. Returns whether the wallpaper is now unlocked
/// (`right(true)` earned, `right(false)` dismissed without reward).
class UnlockWallpaperUseCase {
  final AdsService _adsService;
  final AdPolicyRepository _adPolicyRepository;
  final AppConfigStore _appConfigStore;

  UnlockWallpaperUseCase(
    this._adsService,
    this._adPolicyRepository,
    this._appConfigStore,
  );

  Future<Either<AdsFailure, bool>> execute(String wallpaperId) async {
    final result = await _adsService.showRewarded(
      _appConfigStore.config.ads.rewarded.adUnitId,
    );
    return result.fold(
      (failure) async => left<AdsFailure, bool>(failure),
      (earned) async {
        if (earned) await _adPolicyRepository.markUnlocked(wallpaperId);
        return right<AdsFailure, bool>(earned);
      },
    );
  }
}
