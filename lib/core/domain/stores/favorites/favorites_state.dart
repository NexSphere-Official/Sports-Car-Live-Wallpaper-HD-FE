import '../../models/wallpaper.dart';

class FavoritesState {
  final List<Wallpaper> favorites;
  const FavoritesState({required this.favorites});

  FavoritesState copyWith({List<Wallpaper>? favorites}) =>
      FavoritesState(favorites: favorites ?? this.favorites);
}
