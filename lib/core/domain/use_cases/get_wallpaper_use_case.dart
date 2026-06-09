import 'package:dartz/dartz.dart';
import '../failures/get_wallpapers_failure.dart';
import '../models/wallpaper.dart';
import '../repositories/wallpaper_repository.dart';
import '../stores/app_config/app_config_store.dart';

/// Fetches a single wallpaper by id — `GET /v1/wallpapers/:id`.
class GetWallpaperUseCase {
  final WallpaperRepository _wallpaperRepository;
  final AppConfigStore _appConfigStore;
  GetWallpaperUseCase(this._wallpaperRepository, this._appConfigStore);

  Future<Either<GetWallpapersFailure, Wallpaper>> execute(String id) =>
      _wallpaperRepository.getWallpaperById(
        baseUrl: _appConfigStore.apiBaseUrl,
        id: id,
      );
}
