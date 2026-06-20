import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/app_theme_mode.dart';
import '../../core/domain/stores/favorites/favorites_state.dart';
import '../../core/domain/stores/favorites/favorites_store.dart';
import '../../core/domain/stores/theme/theme_state.dart';
import '../../core/domain/stores/theme/theme_store.dart';
import '../../core/domain/use_cases/clear_cache_use_case.dart';
import '../../core/domain/use_cases/clear_favorites_use_case.dart';
import '../../core/domain/use_cases/get_app_version_use_case.dart';
import '../../core/domain/use_cases/get_privacy_policy_url_use_case.dart';
import '../../core/domain/use_cases/is_privacy_options_required_use_case.dart';
import '../../core/domain/use_cases/rate_app_use_case.dart';
import '../../core/domain/use_cases/set_theme_mode_use_case.dart';
import '../../core/domain/use_cases/share_app_use_case.dart';
import '../../core/domain/use_cases/show_privacy_options_form_use_case.dart';
import '../../core/domain/use_cases/suppress_next_app_open_ad_use_case.dart';
import '../privacy_policy/privacy_policy_initial_params.dart';
import 'settings_initial_params.dart';
import 'settings_navigator.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsInitialParams initialParams;
  final SetThemeModeUseCase _setThemeModeUseCase;
  final ClearCacheUseCase _clearCacheUseCase;
  final ClearFavoritesUseCase _clearFavoritesUseCase;
  final GetAppVersionUseCase _getAppVersionUseCase;
  final ShareAppUseCase _shareAppUseCase;
  final RateAppUseCase _rateAppUseCase;
  final GetPrivacyPolicyUrlUseCase _getPrivacyPolicyUrlUseCase;
  final IsPrivacyOptionsRequiredUseCase _isPrivacyOptionsRequiredUseCase;
  final ShowPrivacyOptionsFormUseCase _showPrivacyOptionsFormUseCase;
  final SuppressNextAppOpenAdUseCase _suppressNextAppOpenAdUseCase;
  final ThemeStore _themeStore;
  final FavoritesStore _favoritesStore;
  final SettingsNavigator navigator;

  StreamSubscription<ThemeStoreState>? _themeSub;
  StreamSubscription<FavoritesState>? _favoritesSub;

  SettingsCubit(
    this.initialParams,
    this._setThemeModeUseCase,
    this._clearCacheUseCase,
    this._clearFavoritesUseCase,
    this._getAppVersionUseCase,
    this._shareAppUseCase,
    this._rateAppUseCase,
    this._getPrivacyPolicyUrlUseCase,
    this._isPrivacyOptionsRequiredUseCase,
    this._showPrivacyOptionsFormUseCase,
    this._suppressNextAppOpenAdUseCase,
    this._themeStore,
    this._favoritesStore,
    this.navigator,
  ) : super(SettingsState.initial(initialParams: initialParams));

  void onInit() {
    emit(
      state.copyWith(
        mode: _themeStore.mode,
        favoritesCount: _favoritesStore.favorites.length,
      ),
    );
    _loadVersion();
    _loadPrivacyOptions();
    _themeSub = _themeStore.stream.listen(
      (s) => emit(state.copyWith(mode: s.mode)),
    );
    _favoritesSub = _favoritesStore.stream.listen(
      (s) => emit(state.copyWith(favoritesCount: s.favorites.length)),
    );
  }

  Future<void> _loadVersion() async {
    final result = await _getAppVersionUseCase.execute();
    result.fold((_) {}, (version) => emit(state.copyWith(version: version)));
  }

  Future<void> _loadPrivacyOptions() async {
    final result = await _isPrivacyOptionsRequiredUseCase.execute();
    final required = result.getOrElse(() => false);
    emit(state.copyWith(isPrivacyOptionsRequired: required));
  }

  Future<void> onTapPrivacyOptions() async {
    await _showPrivacyOptionsFormUseCase.execute();
    // The requirement can change after the user updates choices.
    await _loadPrivacyOptions();
  }

  Future<void> onSelectMode(AppThemeMode mode) =>
      _setThemeModeUseCase.execute(mode);

  Future<void> onTapShare() async {
    // The share sheet backgrounds the app; don't pop an app-open ad on return.
    await _suppressNextAppOpenAdUseCase.execute();
    await _shareAppUseCase.execute();
  }

  Future<void> onTapRate() async {
    // Opening the store listing backgrounds the app; suppress the resume ad.
    await _suppressNextAppOpenAdUseCase.execute();
    await _rateAppUseCase.execute();
  }

  Future<void> onTapPrivacy() async {
    final result = await _getPrivacyPolicyUrlUseCase.execute();
    result.fold(
      (failure) => navigator.showError(failure.displayableFailure().message),
      (url) => navigator.openPrivacyPolicy(
        PrivacyPolicyInitialParams(url: url),
      ),
    );
  }

  Future<void> onTapClearCache() async {
    if (state.isClearingCache) return;
    emit(state.copyWith(isClearingCache: true));
    final result = await _clearCacheUseCase.execute();
    emit(state.copyWith(isClearingCache: false));
    result.fold(
      (failure) => navigator.showError(failure.displayableFailure().message),
      (_) => navigator.showInfo(
        'Cache cleared',
        'Cached images and temporary files were removed.',
      ),
    );
  }

  Future<void> onTapClearFavorites() async {
    if (state.isClearingFavorites) return;
    if (state.favoritesCount == 0) {
      navigator.showInfo(
        'No bookmarks',
        'You haven\'t bookmarked any wallpapers yet.',
      );
      return;
    }
    final confirmed = await navigator.showConfirm(
      title: 'Clear bookmarks?',
      message:
          'This removes all ${state.favoritesCount} bookmarked wallpapers.',
      confirmLabel: 'Clear',
    );
    if (!confirmed) return;
    emit(state.copyWith(isClearingFavorites: true));
    final result = await _clearFavoritesUseCase.execute();
    emit(state.copyWith(isClearingFavorites: false));
    result.fold(
      (failure) => navigator.showError(failure.displayableFailure().message),
      (_) => navigator.showInfo(
        'Bookmarks cleared',
        'All bookmarked wallpapers were removed.',
      ),
    );
  }

  void onTapBack() => navigator.close();

  @override
  Future<void> close() {
    _themeSub?.cancel();
    _favoritesSub?.cancel();
    return super.close();
  }
}
