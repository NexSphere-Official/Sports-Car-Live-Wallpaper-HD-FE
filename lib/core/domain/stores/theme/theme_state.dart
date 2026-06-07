import '../../models/app_theme_mode.dart';

class ThemeStoreState {
  final AppThemeMode mode;
  const ThemeStoreState({required this.mode});

  ThemeStoreState copyWith({AppThemeMode? mode}) =>
      ThemeStoreState(mode: mode ?? this.mode);
}
