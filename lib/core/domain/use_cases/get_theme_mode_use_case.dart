import 'package:dartz/dartz.dart';
import '../failures/settings_failure.dart';
import '../models/app_theme_mode.dart';
import '../repositories/settings_repository.dart';
import '../stores/theme/theme_store.dart';

class GetThemeModeUseCase {
  final SettingsRepository _settingsRepository;
  final ThemeStore _themeStore;
  GetThemeModeUseCase(this._settingsRepository, this._themeStore);

  Future<Either<SettingsFailure, AppThemeMode>> execute() =>
      _settingsRepository.getThemeMode().then(
        (result) => result.fold(left, (mode) {
          _themeStore.setMode(mode);
          return right(mode);
        }),
      );
}
