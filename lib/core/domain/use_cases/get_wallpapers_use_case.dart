import 'package:dartz/dartz.dart';
import '../failures/get_wallpapers_failure.dart';
import '../models/wallpaper_page.dart';
import '../models/wallpaper_type.dart';
import '../repositories/wallpaper_repository.dart';

class GetWallpapersUseCase {
  final WallpaperRepository _wallpaperRepository;
  GetWallpapersUseCase(this._wallpaperRepository);

  Future<Either<GetWallpapersFailure, WallpaperPage>> execute({
    required WallpaperType type,
    int? limit,
    String? cursor,
  }) => _wallpaperRepository.getWallpapers(
    type: type,
    limit: limit,
    cursor: cursor,
  );
}
