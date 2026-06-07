import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/app_theme_mode.dart';
import '../../core/domain/stores/favorites/favorites_state.dart';
import '../../core/domain/stores/favorites/favorites_store.dart';
import '../../core/domain/stores/theme/theme_state.dart';
import '../../core/domain/stores/theme/theme_store.dart';
import '../../core/domain/use_cases/clear_cache_use_case.dart';
import '../../core/domain/use_cases/clear_favorites_use_case.dart';
import '../../core/domain/use_cases/set_theme_mode_use_case.dart';
import 'settings_initial_params.dart';
import 'settings_navigator.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsInitialParams initialParams;
  final SetThemeModeUseCase _setThemeModeUseCase;
  final ClearCacheUseCase _clearCacheUseCase;
  final ClearFavoritesUseCase _clearFavoritesUseCase;
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
    _themeSub = _themeStore.stream.listen(
      (s) => emit(state.copyWith(mode: s.mode)),
    );
    _favoritesSub = _favoritesStore.stream.listen(
      (s) => emit(state.copyWith(favoritesCount: s.favorites.length)),
    );
  }

  Future<void> onSelectMode(AppThemeMode mode) =>
      _setThemeModeUseCase.execute(mode);

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
