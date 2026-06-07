import 'package:dartz/dartz.dart';
import '../failures/settings_failure.dart';
import '../models/wallpaper.dart';
import '../repositories/favorites_repository.dart';
import '../stores/favorites/favorites_store.dart';

class GetFavoritesUseCase {
  final FavoritesRepository _favoritesRepository;
  final FavoritesStore _favoritesStore;
  GetFavoritesUseCase(this._favoritesRepository, this._favoritesStore);

  Future<Either<SettingsFailure, List<Wallpaper>>> execute() =>
      _favoritesRepository.getFavorites().then(
        (result) => result.fold(left, (favorites) {
          _favoritesStore.setFavorites(favorites);
          return right(favorites);
        }),
      );
}
