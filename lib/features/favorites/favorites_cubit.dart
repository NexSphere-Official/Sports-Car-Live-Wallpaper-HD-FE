import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/wallpaper.dart';
import '../../core/domain/stores/favorites/favorites_state.dart';
import '../../core/domain/stores/favorites/favorites_store.dart';
import '../../core/domain/use_cases/get_favorites_use_case.dart';
import '../../core/domain/use_cases/show_back_interstitial_use_case.dart';
import '../../core/domain/use_cases/toggle_favorite_use_case.dart';
import 'favorites_initial_params.dart';
import 'favorites_navigator.dart';
import 'favorites_state.dart';
import '../wallpaper_detail/wallpaper_detail_initial_params.dart';

class FavoritesCubit extends Cubit<FavoritesPageState> {
  final FavoritesInitialParams initialParams;
  final GetFavoritesUseCase _getFavoritesUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final ShowBackInterstitialUseCase _showBackInterstitialUseCase;
  final FavoritesStore _favoritesStore;
  final FavoritesNavigator navigator;

  StreamSubscription<FavoritesState>? _favoritesSub;

  FavoritesCubit(
    this.initialParams,
    this._getFavoritesUseCase,
    this._toggleFavoriteUseCase,
    this._showBackInterstitialUseCase,
    this._favoritesStore,
    this.navigator,
  ) : super(FavoritesPageState.initial(initialParams: initialParams));

  Future<void> onInit() async {
    emit(state.copyWith(isLoading: true, favorites: _favoritesStore.favorites));
    _favoritesSub = _favoritesStore.stream.listen(
      (s) => emit(state.copyWith(favorites: s.favorites)),
    );
    await _getFavoritesUseCase.execute();
    emit(
      state.copyWith(isLoading: false, favorites: _favoritesStore.favorites),
    );
  }

  Future<void> onToggleFavorite(Wallpaper wallpaper) =>
      _toggleFavoriteUseCase.execute(wallpaper);

  void onTapWallpaper(Wallpaper wallpaper) => navigator.openWallpaperDetail(
    WallpaperDetailInitialParams(wallpaper: wallpaper),
  );

  /// Single exit path for the Saved page — used by both the header back button
  /// and the system back gesture (via PopScope). Navigates back first, then
  /// shows the interstitial over the revealed screen. The [_leaving] guard
  /// ensures it only runs once if both triggers fire.
  bool _leaving = false;

  void onTapBack() {
    if (_leaving) return;
    _leaving = true;
    navigator.close();
    // No-op when ads/flag/consent are off; the shared cooldown prevents
    // stacking. Fire-and-forget over the previous screen.
    unawaited(_showBackInterstitialUseCase.execute());
  }

  @override
  Future<void> close() {
    _favoritesSub?.cancel();
    return super.close();
  }
}
