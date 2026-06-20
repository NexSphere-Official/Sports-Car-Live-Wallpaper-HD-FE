import 'package:dartz/dartz.dart';

import '../failures/settings_failure.dart';
import '../models/app_theme_mode.dart';
import '../repositories/settings_repository.dart';
import '../stores/theme/theme_store.dart';

class SetThemeModeUseCase {
  final SettingsRepository _settingsRepository;
  final ThemeStore _themeStore;
  SetThemeModeUseCase(this._settingsRepository, this._themeStore);

  /// Persists the theme, then updates the global store only on success — so the
  /// UI never diverges from what's actually saved, and a failure is surfaced.
  Future<Either<SettingsFailure, Unit>> execute(AppThemeMode mode) async {
    final result = await _settingsRepository.saveThemeMode(mode);
    return result.fold(left, (_) {
      _themeStore.setMode(mode);
      return right(unit);
    });
  }
}
