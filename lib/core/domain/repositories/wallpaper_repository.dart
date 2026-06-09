import 'package:dartz/dartz.dart';
import '../failures/get_wallpapers_failure.dart';
import '../models/wallpaper.dart';
import '../models/wallpaper_page.dart';
import '../models/wallpaper_type.dart';

abstract class WallpaperRepository {
  /// Fetches one page of the [type] feed. Pass [cursor] (an opaque
  /// `next_cursor`) to load the next page; omit it for the first page.
  Future<Either<GetWallpapersFailure, WallpaperPage>> getWallpapers({
    required WallpaperType type,
    int? limit,
    String? cursor,
  });

  /// Fetches a single wallpaper by id (`s_001`, `l_010`, …).
  Future<Either<GetWallpapersFailure, Wallpaper>> getWallpaperById(String id);
}
