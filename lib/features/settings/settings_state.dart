import '../../core/domain/models/app_theme_mode.dart';
import 'settings_initial_params.dart';

class SettingsState {
  final AppThemeMode mode;
  final int favoritesCount;
  final bool isClearingCache;
  final bool isClearingFavorites;
  final String version;

  /// Whether to surface the UMP privacy-options entry (required in regulated
  /// regions once consent info has been gathered).
  final bool isPrivacyOptionsRequired;

  const SettingsState({
    required this.mode,
    required this.favoritesCount,
    required this.isClearingCache,
    required this.isClearingFavorites,
    required this.version,
    required this.isPrivacyOptionsRequired,
  });

  factory SettingsState.initial({
    required SettingsInitialParams initialParams,
  }) => const SettingsState(
    mode: AppThemeMode.system,
    favoritesCount: 0,
    isClearingCache: false,
    isClearingFavorites: false,
    version: '',
    isPrivacyOptionsRequired: false,
  );

  SettingsState copyWith({
    AppThemeMode? mode,
    int? favoritesCount,
    bool? isClearingCache,
    bool? isClearingFavorites,
    String? version,
    bool? isPrivacyOptionsRequired,
  }) => SettingsState(
    mode: mode ?? this.mode,
    favoritesCount: favoritesCount ?? this.favoritesCount,
    isClearingCache: isClearingCache ?? this.isClearingCache,
    isClearingFavorites: isClearingFavorites ?? this.isClearingFavorites,
    version: version ?? this.version,
    isPrivacyOptionsRequired:
        isPrivacyOptionsRequired ?? this.isPrivacyOptionsRequired,
  );
}
