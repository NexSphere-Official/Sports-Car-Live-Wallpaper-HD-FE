import 'package:dartz/dartz.dart';
import '../failures/get_wallpapers_failure.dart';
import '../models/wallpaper.dart';
import '../repositories/wallpaper_repository.dart';

/// Fetches a single wallpaper by id — `GET /v1/wallpapers/:id`.
class GetWallpaperUseCase {
  final WallpaperRepository _wallpaperRepository;
  GetWallpaperUseCase(this._wallpaperRepository);

  Future<Either<GetWallpapersFailure, Wallpaper>> execute(String id) =>
      _wallpaperRepository.getWallpaperById(id);
}
