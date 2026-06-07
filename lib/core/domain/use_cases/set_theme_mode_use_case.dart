import '../models/app_theme_mode.dart';
import '../repositories/settings_repository.dart';
import '../stores/theme/theme_store.dart';

class SetThemeModeUseCase {
  final SettingsRepository _settingsRepository;
  final ThemeStore _themeStore;
  SetThemeModeUseCase(this._settingsRepository, this._themeStore);

  Future<void> execute(AppThemeMode mode) async {
    _themeStore.setMode(mode);
    await _settingsRepository.saveThemeMode(mode);
  }
}
