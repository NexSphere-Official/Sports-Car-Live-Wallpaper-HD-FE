import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/wallpaper.dart';
import '../../core/domain/models/wallpaper_page.dart';
import '../../core/domain/models/wallpaper_type.dart';
import '../../core/domain/stores/ads/ads_store.dart';
import '../../core/domain/stores/app_config/app_config_store.dart';
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
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;
  final HomeNavigator navigator;

  static const _pageSize = 50;
  static const _maxInitialAttempts = 3;
  StreamSubscription<FavoritesState>? _favoritesSub;

  HomeCubit(
    this.initialParams,
    this._getWallpapersUseCase,
    this._toggleFavoriteUseCase,
    this._favoritesStore,
    this._appConfigStore,
    this._adsStore,
    this.navigator,
  ) : super(HomeState.initial(initialParams: initialParams));

  void onInit() {
    emit(
      state.copyWith(
        favoriteIds: _favoriteIds(),
        nativeAdsEnabled: _nativeAdsEnabled,
        nativeAdUnitId: _appConfigStore.config.ads.native.adUnitId,
        nativeAdInterval: _appConfigStore.config.ads.native.gridInterval,
      ),
    );
    _favoritesSub = _favoritesStore.stream.listen(
      (_) => emit(state.copyWith(favoriteIds: _favoriteIds())),
    );
    _loadFirstPage();
  }

  bool get _nativeAdsEnabled {
    final ads = _appConfigStore.config.ads;
    // Runtime gate: consent given + SDK initialized, not just Remote Config.
    return _adsStore.canRequestAds && ads.enabled && ads.native.isUsable;
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
        type: state.type,
        limit: _pageSize,
      );
      final loaded = result.fold((failure) => false, (page) {
        emit(
          state.copyWith(
            isInitialLoading: false,
            hasError: false,
            wallpapers: page.wallpapers,
            nextCursor: page.nextCursor,
            hasReachedEnd: !page.hasMore,
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
        state.hasError ||
        state.nextCursor == null) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    final result = await _getWallpapersUseCase.execute(
      type: state.type,
      limit: _pageSize,
      cursor: state.nextCursor,
    );
    result.fold((failure) => emit(state.copyWith(isLoadingMore: false)), (
      WallpaperPage page,
    ) {
      // De-dupe against what we already show to guard against any overlap.
      final existing = state.wallpapers.map((w) => w.id).toSet();
      final fresh = page.wallpapers
          .where((w) => !existing.contains(w.id))
          .toList();
      emit(
        state.copyWith(
          isLoadingMore: false,
          wallpapers: [...state.wallpapers, ...fresh],
          nextCursor: page.nextCursor,
          hasReachedEnd: !page.hasMore,
        ),
      );
    });
  }

  void onSelectType(WallpaperType type) {
    if (state.type == type) return;
    emit(state.copyWith(type: type, wallpapers: const [], nextCursor: null));
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

  @override
  Future<void> close() {
    _favoritesSub?.cancel();
    return super.close();
  }
}
