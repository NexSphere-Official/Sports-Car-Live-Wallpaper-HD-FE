import 'package:dartz/dartz.dart';

import '../failures/settings_failure.dart';
import '../models/ads_config.dart';
import '../models/wallpaper_ad_gate.dart';
import '../repositories/ad_policy_repository.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';

/// Determines a wallpaper's [WallpaperAdGate] for the detail page. Assigns and
/// persists an [AdSlotType] from the unlock pattern the first time a wallpaper
/// is seen, then reflects its stored unlock state on subsequent opens.
class ResolveWallpaperAdSlotUseCase {
  final AdPolicyRepository _adPolicyRepository;
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;

  ResolveWallpaperAdSlotUseCase(
    this._adPolicyRepository,
    this._appConfigStore,
    this._adsStore,
  );

  Future<Either<SettingsFailure, WallpaperAdGate>> execute(
    String wallpaperId,
  ) async {
    final ads = _appConfigStore.config.ads;

    // Ads off, or can't be served at runtime (consent denied / SDK not ready)
    // → open gate, and don't burn a pattern slot. Avoids ever showing a locked
    // wallpaper whose rewarded ad could never load.
    if (!ads.enabled || !_adsStore.canRequestAds) {
      return right(WallpaperAdGate.empty());
    }

    final slotResult = await _resolveSlot(wallpaperId, ads);
    return slotResult.fold(
      (failure) async => left<SettingsFailure, WallpaperAdGate>(failure),
      (slot) async {
        if (slot == AdSlotType.interstitial) {
          return right<SettingsFailure, WallpaperAdGate>(
            const WallpaperAdGate(
              slot: AdSlotType.interstitial,
              isUnlocked: false,
            ),
          );
        }
        // Rewarded slot. If rewarded ads can't be served, never lock the
        // wallpaper (otherwise it would be unusable).
        if (!ads.rewarded.isUsable) {
          return right<SettingsFailure, WallpaperAdGate>(
            WallpaperAdGate.empty(),
          );
        }

        final unlocked = await _adPolicyRepository.isUnlocked(wallpaperId);
        return unlocked.map(
          (isUnlocked) =>
              WallpaperAdGate(slot: AdSlotType.rewarded, isUnlocked: isUnlocked),
        );
      },
    );
  }

  /// Returns the wallpaper's persisted slot, assigning the next one from the
  /// pattern if it hasn't been seen before.
  Future<Either<SettingsFailure, AdSlotType>> _resolveSlot(
    String wallpaperId,
    AdsConfig ads,
  ) async {
    final existing = await _adPolicyRepository.assignedSlot(wallpaperId);
    return existing.fold(
      (failure) async => left<SettingsFailure, AdSlotType>(failure),
      (existing) async {
        if (existing != null) {
          return right<SettingsFailure, AdSlotType>(existing);
        }

        final countResult = await _adPolicyRepository.assignedCount();
        final count = countResult.getOrElse(() => 0);
        final slot = ads.slotTypeForIndex(count);

        final saved = await _adPolicyRepository.saveSlot(wallpaperId, slot);
        return saved.map((_) => slot);
      },
    );
  }
}
