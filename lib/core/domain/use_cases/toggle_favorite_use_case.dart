import '../models/wallpaper.dart';
import '../repositories/favorites_repository.dart';
import '../stores/favorites/favorites_store.dart';

class ToggleFavoriteUseCase {
  final FavoritesRepository _favoritesRepository;
  final FavoritesStore _favoritesStore;
  ToggleFavoriteUseCase(this._favoritesRepository, this._favoritesStore);

  Future<void> execute(Wallpaper wallpaper) async {
    _favoritesStore.toggle(wallpaper);
    await _favoritesRepository.saveFavorites(_favoritesStore.favorites);
  }
}
