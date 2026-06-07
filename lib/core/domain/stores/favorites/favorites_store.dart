import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/wallpaper.dart';
import 'favorites_state.dart';

class FavoritesStore extends Cubit<FavoritesState> {
  FavoritesStore() : super(const FavoritesState(favorites: []));

  List<Wallpaper> get favorites => state.favorites;

  bool isFavorite(Wallpaper wallpaper) =>
      state.favorites.any((w) => w.id == wallpaper.id);

  void setFavorites(List<Wallpaper> favorites) =>
      emit(state.copyWith(favorites: favorites));

  void toggle(Wallpaper wallpaper) {
    if (isFavorite(wallpaper)) {
      emit(
        state.copyWith(
          favorites: state.favorites
              .where((w) => w.id != wallpaper.id)
              .toList(),
        ),
      );
    } else {
      emit(state.copyWith(favorites: [wallpaper, ...state.favorites]));
    }
  }
}
