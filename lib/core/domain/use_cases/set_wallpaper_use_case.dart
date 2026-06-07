import 'package:dartz/dartz.dart';
import '../failures/set_wallpaper_failure.dart';
import '../models/wallpaper.dart';
import '../models/wallpaper_surface.dart';
import '../repositories/wallpaper_setter_repository.dart';

class SetWallpaperUseCase {
  final WallpaperSetterRepository _wallpaperSetterRepository;
  SetWallpaperUseCase(this._wallpaperSetterRepository);

  Future<Either<SetWallpaperFailure, Unit>> execute(
    Wallpaper wallpaper, {
    WallpaperSurface surface = WallpaperSurface.both,
  }) {
    if (wallpaper.isLive) {
      return _wallpaperSetterRepository.setLive(wallpaper.videoUrl);
    }
    final imageUrl = wallpaper.imageUrl.isNotEmpty
        ? wallpaper.imageUrl
        : wallpaper.previewUrl;
    return _wallpaperSetterRepository.setStatic(imageUrl, surface);
  }
}
