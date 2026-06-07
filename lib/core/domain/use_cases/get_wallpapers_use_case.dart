import 'package:dartz/dartz.dart';
import '../failures/get_wallpapers_failure.dart';
import '../models/wallpaper.dart';
import '../models/wallpaper_filter.dart';
import '../repositories/wallpaper_repository.dart';

class GetWallpapersUseCase {
  final WallpaperRepository _wallpaperRepository;
  GetWallpapersUseCase(this._wallpaperRepository);

  Future<Either<GetWallpapersFailure, List<Wallpaper>>> execute({
    required WallpaperFilter filter,
    required int limit,
    required int offset,
  }) => _wallpaperRepository.getWallpapers(
    filter: filter,
    limit: limit,
    offset: offset,
  );
}
