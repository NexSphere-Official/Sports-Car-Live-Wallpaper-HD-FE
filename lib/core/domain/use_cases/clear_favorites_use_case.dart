import 'package:dartz/dartz.dart';
import '../failures/settings_failure.dart';
import '../repositories/favorites_repository.dart';
import '../stores/favorites/favorites_store.dart';

class ClearFavoritesUseCase {
  final FavoritesRepository _favoritesRepository;
  final FavoritesStore _favoritesStore;
  ClearFavoritesUseCase(this._favoritesRepository, this._favoritesStore);

  Future<Either<SettingsFailure, Unit>> execute() {
    _favoritesStore.setFavorites(const []);
    return _favoritesRepository.saveFavorites(const []);
  }
}
