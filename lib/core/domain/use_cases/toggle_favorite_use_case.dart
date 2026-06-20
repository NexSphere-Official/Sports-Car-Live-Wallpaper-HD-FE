import 'package:dartz/dartz.dart';

import '../failures/settings_failure.dart';
import '../models/wallpaper.dart';
import '../repositories/favorites_repository.dart';
import '../stores/favorites/favorites_store.dart';

class ToggleFavoriteUseCase {
  final FavoritesRepository _favoritesRepository;
  final FavoritesStore _favoritesStore;
  ToggleFavoriteUseCase(this._favoritesRepository, this._favoritesStore);

  /// Computes the toggled list, persists it, then updates the global store only
  /// on success — so the favorites UI never diverges from what's saved, and a
  /// persistence failure is surfaced instead of silently swallowed.
  Future<Either<SettingsFailure, Unit>> execute(Wallpaper wallpaper) async {
    final current = _favoritesStore.favorites;
    final isFavorite = current.any((w) => w.id == wallpaper.id);
    final updated = isFavorite
        ? current.where((w) => w.id != wallpaper.id).toList()
        : [wallpaper, ...current];

    final result = await _favoritesRepository.saveFavorites(updated);
    return result.fold(left, (_) {
      _favoritesStore.setFavorites(updated);
      return right(unit);
    });
  }
}
