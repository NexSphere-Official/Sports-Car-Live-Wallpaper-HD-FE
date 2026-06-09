import 'package:dartz/dartz.dart';
import '../failures/get_wallpapers_failure.dart';
import '../models/wallpaper_page.dart';
import '../models/wallpaper_type.dart';
import '../repositories/wallpaper_repository.dart';
import '../stores/app_config/app_config_store.dart';

class GetWallpapersUseCase {
  final WallpaperRepository _wallpaperRepository;
  final AppConfigStore _appConfigStore;
  GetWallpapersUseCase(this._wallpaperRepository, this._appConfigStore);

  Future<Either<GetWallpapersFailure, WallpaperPage>> execute({
    required WallpaperType type,
    int? limit,
    String? cursor,
  }) => _wallpaperRepository.getWallpapers(
    baseUrl: _appConfigStore.apiBaseUrl,
    type: type,
    limit: limit,
    cursor: cursor,
  );
}
