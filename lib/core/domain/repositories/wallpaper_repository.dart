import 'package:dartz/dartz.dart';
import '../failures/get_wallpapers_failure.dart';
import '../models/wallpaper.dart';
import '../models/wallpaper_page.dart';
import '../models/wallpaper_type.dart';

abstract class WallpaperRepository {
  /// Fetches one page of the [type] feed from [baseUrl]. Pass [cursor] (an
  /// opaque `next_cursor`) to load the next page; omit it for the first page.
  Future<Either<GetWallpapersFailure, WallpaperPage>> getWallpapers({
    required String baseUrl,
    required WallpaperType type,
    int? limit,
    String? cursor,
  });

  /// Fetches a single wallpaper by id (`s_001`, `l_010`, …) from [baseUrl].
  Future<Either<GetWallpapersFailure, Wallpaper>> getWallpaperById({
    required String baseUrl,
    required String id,
  });
}
