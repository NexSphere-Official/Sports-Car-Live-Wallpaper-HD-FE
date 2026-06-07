import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/failures/settings_failure.dart';
import '../../domain/models/app_theme_mode.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  @override
  Future<Either<SettingsFailure, AppThemeMode>> getThemeMode() async {
    try {
      final raw = _prefs.getString(_key);
      return right(_parse(raw));
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  @override
  Future<Either<SettingsFailure, Unit>> saveThemeMode(AppThemeMode mode) async {
    try {
      await _prefs.setString(_key, mode.name);
      return right(unit);
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  AppThemeMode _parse(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }
}
