import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/failures/settings_failure.dart';
import '../../domain/models/ads_config.dart';
import '../../domain/repositories/ad_policy_repository.dart';

class SharedPrefsAdPolicyRepository implements AdPolicyRepository {
  SharedPrefsAdPolicyRepository(this._prefs);

  final SharedPreferences _prefs;

  /// JSON map of `{ wallpaperId: slotName }`.
  static const _slotsKey = 'ad_slot_assignments';

  /// String list of unlocked wallpaper ids.
  static const _unlockedKey = 'ad_unlocked_ids';

  @override
  Future<Either<SettingsFailure, AdSlotType?>> assignedSlot(
    String wallpaperId,
  ) async {
    try {
      final name = _readSlots()[wallpaperId];
      return right(name == null ? null : AdSlotType.fromKey(name));
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  @override
  Future<Either<SettingsFailure, int>> assignedCount() async {
    try {
      return right(_readSlots().length);
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  @override
  Future<Either<SettingsFailure, Unit>> saveSlot(
    String wallpaperId,
    AdSlotType slot,
  ) async {
    try {
      final slots = _readSlots()..[wallpaperId] = slot.name;
      await _prefs.setString(_slotsKey, jsonEncode(slots));
      return right(unit);
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  @override
  Future<Either<SettingsFailure, bool>> isUnlocked(String wallpaperId) async {
    try {
      return right(_readUnlocked().contains(wallpaperId));
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  @override
  Future<Either<SettingsFailure, Unit>> markUnlocked(String wallpaperId) async {
    try {
      final unlocked = _readUnlocked()..add(wallpaperId);
      await _prefs.setStringList(_unlockedKey, unlocked.toList());
      return right(unit);
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  Map<String, String> _readSlots() {
    final raw = _prefs.getString(_slotsKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  Set<String> _readUnlocked() =>
      (_prefs.getStringList(_unlockedKey) ?? const <String>[]).toSet();
}
