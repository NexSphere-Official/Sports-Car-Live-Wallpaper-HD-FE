import '../../core/domain/models/wallpaper.dart';
import 'favorites_initial_params.dart';

class FavoritesPageState {
  final List<Wallpaper> favorites;
  final bool isLoading;

  bool get isEmpty => favorites.isEmpty && !isLoading;

  const FavoritesPageState({required this.favorites, required this.isLoading});

  factory FavoritesPageState.initial({
    required FavoritesInitialParams initialParams,
  }) => const FavoritesPageState(favorites: [], isLoading: false);

  FavoritesPageState copyWith({List<Wallpaper>? favorites, bool? isLoading}) =>
      FavoritesPageState(
        favorites: favorites ?? this.favorites,
        isLoading: isLoading ?? this.isLoading,
      );
}
