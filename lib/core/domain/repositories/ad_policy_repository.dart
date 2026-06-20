import 'package:dartz/dartz.dart';

import '../failures/settings_failure.dart';
import '../models/ads_config.dart';

/// Persists per-wallpaper ad policy: which [AdSlotType] each wallpaper was
/// assigned (stable across opens).
///
/// Unlock state is intentionally NOT persisted here — it lives in
/// [SessionUnlockStore] and lasts only for the current app session.
abstract class AdPolicyRepository {
  /// The slot type previously assigned to a wallpaper, or null if not yet seen.
  Future<Either<SettingsFailure, AdSlotType?>> assignedSlot(String wallpaperId);

  /// How many wallpapers have been assigned a slot so far — drives the next
  /// index into the unlock pattern.
  Future<Either<SettingsFailure, int>> assignedCount();

  /// Persist the slot assigned to a wallpaper.
  Future<Either<SettingsFailure, Unit>> saveSlot(
    String wallpaperId,
    AdSlotType slot,
  );
}
