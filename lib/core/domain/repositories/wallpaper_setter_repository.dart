import 'package:dartz/dartz.dart';
import '../failures/set_wallpaper_failure.dart';
import '../models/wallpaper_surface.dart';

abstract class WallpaperSetterRepository {
  Future<Either<SetWallpaperFailure, Unit>> setStatic(
    String imageUrl,
    WallpaperSurface surface,
  );
  Future<Either<SetWallpaperFailure, Unit>> setLive(String videoUrl);
}
