import 'package:equatable/equatable.dart';

import 'ads_config.dart';

/// The ad gate for a single wallpaper's apply flow, derived from its assigned
/// [AdSlotType] and persisted unlock state.
///
/// - rewarded + not unlocked → [isLocked]: tap "Unlock" → rewarded ad.
/// - rewarded + unlocked     → applies freely, no ad.
/// - interstitial            → [requiresInterstitial]: interstitial before apply.
class WallpaperAdGate extends Equatable {
  final AdSlotType slot;
  final bool isUnlocked;

  const WallpaperAdGate({required this.slot, required this.isUnlocked});

  /// Open gate — applies directly with no ad (used when ads are disabled or the
  /// relevant ad unit is unavailable).
  factory WallpaperAdGate.open() =>
      const WallpaperAdGate(slot: AdSlotType.rewarded, isUnlocked: true);

  bool get isLocked => slot == AdSlotType.rewarded && !isUnlocked;

  bool get requiresInterstitial => slot == AdSlotType.interstitial;

  WallpaperAdGate copyWith({AdSlotType? slot, bool? isUnlocked}) =>
      WallpaperAdGate(
        slot: slot ?? this.slot,
        isUnlocked: isUnlocked ?? this.isUnlocked,
      );

  @override
  List<Object?> get props => [slot, isUnlocked];
}
