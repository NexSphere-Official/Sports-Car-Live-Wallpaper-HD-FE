import '../../core/domain/models/app_theme_mode.dart';
import 'settings_initial_params.dart';

class SettingsState {
  final AppThemeMode mode;
  final int favoritesCount;
  final bool isClearingCache;
  final bool isClearingFavorites;

  const SettingsState({
    required this.mode,
    required this.favoritesCount,
    required this.isClearingCache,
    required this.isClearingFavorites,
  });

  factory SettingsState.initial({
    required SettingsInitialParams initialParams,
  }) => const SettingsState(
    mode: AppThemeMode.system,
    favoritesCount: 0,
    isClearingCache: false,
    isClearingFavorites: false,
  );

  SettingsState copyWith({
    AppThemeMode? mode,
    int? favoritesCount,
    bool? isClearingCache,
    bool? isClearingFavorites,
  }) => SettingsState(
    mode: mode ?? this.mode,
    favoritesCount: favoritesCount ?? this.favoritesCount,
    isClearingCache: isClearingCache ?? this.isClearingCache,
    isClearingFavorites: isClearingFavorites ?? this.isClearingFavorites,
  );
}
