import 'package:dartz/dartz.dart';
import '../failures/settings_failure.dart';
import '../models/wallpaper.dart';

abstract class FavoritesRepository {
  Future<Either<SettingsFailure, List<Wallpaper>>> getFavorites();
  Future<Either<SettingsFailure, Unit>> saveFavorites(
    List<Wallpaper> favorites,
  );
}
