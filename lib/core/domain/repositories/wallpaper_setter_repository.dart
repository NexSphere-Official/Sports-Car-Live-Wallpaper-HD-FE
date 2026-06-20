import 'package:dartz/dartz.dart';
import '../failures/set_wallpaper_failure.dart';
import '../models/wallpaper_surface.dart';

abstract class WallpaperSetterRepository {
  Future<Either<SetWallpaperFailure, Unit>> setStatic(
    String imageUrl,
    WallpaperSurface surface,
  );
  Future<Either<SetWallpaperFailure, Unit>> setLive(String videoUrl);

  /// Whether this app's live wallpaper is the device's currently-active one —
  /// used after returning from the system live-wallpaper preview to confirm the
  /// user actually applied it.
  Future<Either<SetWallpaperFailure, bool>> isLiveWallpaperActive();
}
