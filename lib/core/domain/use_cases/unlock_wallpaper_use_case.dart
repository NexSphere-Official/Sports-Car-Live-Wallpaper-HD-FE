import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ad_policy_repository.dart';
import '../repositories/ads_service.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';

/// Shows a rewarded ad to unlock a locked wallpaper. On an earned reward the
/// unlock is persisted. Returns whether the wallpaper is now unlocked
/// (`right(true)` earned, `right(false)` dismissed without reward); `left` on a
/// load/show error or if the unlock could not be persisted.
class UnlockWallpaperUseCase {
  final AdsService _adsService;
  final AdPolicyRepository _adPolicyRepository;
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;

  UnlockWallpaperUseCase(
    this._adsService,
    this._adPolicyRepository,
    this._appConfigStore,
    this._adsStore,
  );

  Future<Either<AdsFailure, bool>> execute(String wallpaperId) async {
    // Consent revoked (or SDK not ready) while the page was open: ads can't be
    // requested, so treat the wallpaper as freely usable for this session
    // rather than requesting a rewarded ad.
    if (!_adsStore.canRequestAds) return right(true);

    final result = await _adsService.showRewarded(
      _appConfigStore.config.ads.rewarded.adUnitId,
    );
    return result.fold(
      (failure) async => left<AdsFailure, bool>(failure),
      (earned) async {
        if (!earned) return right<AdsFailure, bool>(false);
        // Reward earned — persist the unlock. Surface (don't swallow) a
        // persistence failure so the user isn't told it's unlocked when it
        // won't survive a relaunch.
        final saved = await _adPolicyRepository.markUnlocked(wallpaperId);
        return saved.fold(
          (_) => left<AdsFailure, bool>(
            const AdsFailure.unknown('failed to persist unlock'),
          ),
          (_) => right<AdsFailure, bool>(true),
        );
      },
    );
  }
}
