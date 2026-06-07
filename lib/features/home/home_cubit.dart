import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/wallpaper.dart';
import '../../core/domain/models/wallpaper_filter.dart';
import '../../core/domain/stores/favorites/favorites_state.dart';
import '../../core/domain/stores/favorites/favorites_store.dart';
import '../../core/domain/use_cases/get_wallpapers_use_case.dart';
import '../../core/domain/use_cases/toggle_favorite_use_case.dart';
import 'home_initial_params.dart';
import 'home_navigator.dart';
import 'home_state.dart';
import '../favorites/favorites_initial_params.dart';
import '../settings/settings_initial_params.dart';
import '../wallpaper_detail/wallpaper_detail_initial_params.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeInitialParams initialParams;
  final GetWallpapersUseCase _getWallpapersUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final FavoritesStore _favoritesStore;
  final HomeNavigator navigator;

  static const _pageSize = 50;
  static const _maxInitialAttempts = 3;
  final Random _random = Random();
  StreamSubscription<FavoritesState>? _favoritesSub;

  HomeCubit(
    this.initialParams,
    this._getWallpapersUseCase,
    this._toggleFavoriteUseCase,
    this._favoritesStore,
    this.navigator,
  ) : super(HomeState.initial(initialParams: initialParams));

  void onInit() {
    emit(state.copyWith(favoriteIds: _favoriteIds()));
    _favoritesSub = _favoritesStore.stream.listen(
      (_) => emit(state.copyWith(favoriteIds: _favoriteIds())),
    );
    _loadFirstPage();
  }

  Future<void> onRefresh() => _loadFirstPage();

  Future<void> _loadFirstPage() async {
    emit(
      state.copyWith(
        isInitialLoading: true,
        hasError: false,
        hasReachedEnd: false,
      ),
    );

    // The first request after a cold start can fail before the network/DNS
    // stack is ready, so retry a few times with backoff before giving up.
    for (var attempt = 0; attempt < _maxInitialAttempts; attempt++) {
      final result = await _getWallpapersUseCase.execute(
        filter: state.filter,
        limit: _pageSize,
        offset: 0,
      );
      final loaded = result.fold((failure) => false, (wallpapers) {
        emit(
          state.copyWith(
            isInitialLoading: false,
            hasError: false,
            wallpapers: _maybeShuffle(wallpapers),
            hasReachedEnd: wallpapers.length < _pageSize,
          ),
        );
        return true;
      });
      if (loaded) return;
      if (attempt < _maxInitialAttempts - 1) {
        await Future.delayed(Duration(milliseconds: 700 * (attempt + 1)));
      }
    }

    emit(
      state.copyWith(
        isInitialLoading: false,
        hasError: true,
        wallpapers: const [],
      ),
    );
  }

  Future<void> onLoadMore() async {
    if (state.isLoadingMore ||
        state.isInitialLoading ||
        state.hasReachedEnd ||
        state.hasError) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    final result = await _getWallpapersUseCase.execute(
      filter: state.filter,
      limit: _pageSize,
      offset: state.wallpapers.length,
    );
    result.fold((failure) => emit(state.copyWith(isLoadingMore: false)), (
      more,
    ) {
      // De-dupe against what we already show (random sort can repeat ids).
      final existing = state.wallpapers.map((w) => w.id).toSet();
      final fresh = more.where((w) => !existing.contains(w.id)).toList();
      emit(
        state.copyWith(
          isLoadingMore: false,
          wallpapers: [...state.wallpapers, ..._maybeShuffle(fresh)],
          hasReachedEnd: more.length < _pageSize,
        ),
      );
    });
  }

  void onSelectType(WallpaperType type) {
    if (state.filter.type == type) return;
    emit(state.copyWith(filter: state.filter.copyWith(type: type)));
    _loadFirstPage();
  }

  Future<void> onToggleFavorite(Wallpaper wallpaper) =>
      _toggleFavoriteUseCase.execute(wallpaper);

  void onTapWallpaper(Wallpaper wallpaper) => navigator.openWallpaperDetail(
    WallpaperDetailInitialParams(wallpaper: wallpaper),
  );

  void onTapFavorites() =>
      navigator.openFavorites(const FavoritesInitialParams());

  void onTapSettings() => navigator.openSettings(const SettingsInitialParams());

  Set<String> _favoriteIds() =>
      _favoritesStore.favorites.map((w) => w.id).toSet();

  /// Reshuffle locally so a fresh order appears on every random load.
  List<Wallpaper> _maybeShuffle(List<Wallpaper> wallpapers) {
    if (!state.filter.isRandom) return wallpapers;
    final shuffled = [...wallpapers]..shuffle(_random);
    return shuffled;
  }

  @override
  Future<void> close() {
    _favoritesSub?.cancel();
    return super.close();
  }
}
