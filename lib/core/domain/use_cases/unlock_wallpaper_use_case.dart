import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';
import '../stores/unlock/session_unlock_store.dart';

/// Shows a rewarded ad to unlock a locked wallpaper. On an earned reward the
/// unlock is recorded for the current session only (see [SessionUnlockStore]) —
/// it is not persisted, so a relaunch re-locks the wallpaper. Returns whether
/// the wallpaper is now unlocked (`right(true)` earned, `right(false)` dismissed
/// without reward); `left` on a load/show error.
class UnlockWallpaperUseCase {
  final AdsService _adsService;
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;
  final SessionUnlockStore _sessionUnlockStore;

  UnlockWallpaperUseCase(
    this._adsService,
    this._appConfigStore,
    this._adsStore,
    this._sessionUnlockStore,
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
      (failure) => left<AdsFailure, bool>(failure),
      (earned) {
        if (!earned) return right<AdsFailure, bool>(false);
        // Reward earned — record the unlock for this session only. Not
        // persisted, so the wallpaper re-locks on the next app launch.
        _sessionUnlockStore.markUnlocked(wallpaperId);
        return right<AdsFailure, bool>(true);
      },
    );
  }
}
