import 'package:dartz/dartz.dart';
import '../failures/get_wallpapers_failure.dart';
import '../models/wallpaper.dart';
import '../models/wallpaper_filter.dart';

abstract class WallpaperRepository {
  Future<Either<GetWallpapersFailure, List<Wallpaper>>> getWallpapers({
    required WallpaperFilter filter,
    required int limit,
    required int offset,
  });
}
