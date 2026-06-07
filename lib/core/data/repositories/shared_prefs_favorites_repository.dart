import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper_json.dart';
import '../../domain/failures/settings_failure.dart';
import '../../domain/models/wallpaper.dart';
import '../../domain/repositories/favorites_repository.dart';

class SharedPrefsFavoritesRepository implements FavoritesRepository {
  SharedPrefsFavoritesRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'favorites';

  @override
  Future<Either<SettingsFailure, List<Wallpaper>>> getFavorites() async {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null || raw.isEmpty) return right(const []);
      final decoded = jsonDecode(raw) as List<dynamic>;
      final favorites = decoded
          .whereType<Map<String, dynamic>>()
          .map((json) => WallpaperJson.fromJson(json).toDomain())
          .toList();
      return right(favorites);
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  @override
  Future<Either<SettingsFailure, Unit>> saveFavorites(
    List<Wallpaper> favorites,
  ) async {
    try {
      final encoded = jsonEncode(
        favorites.map((w) => WallpaperJson.fromDomain(w).toJson()).toList(),
      );
      await _prefs.setString(_key, encoded);
      return right(unit);
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }
}
