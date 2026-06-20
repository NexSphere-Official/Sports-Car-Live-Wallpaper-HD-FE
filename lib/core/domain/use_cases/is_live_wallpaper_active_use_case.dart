import 'package:dartz/dartz.dart';

import '../failures/set_wallpaper_failure.dart';
import '../repositories/wallpaper_setter_repository.dart';

/// Whether this app's live wallpaper is currently active on the device. Used
/// after the user returns from the system live-wallpaper preview to confirm
/// they actually applied it.
class IsLiveWallpaperActiveUseCase {
  final WallpaperSetterRepository _wallpaperSetterRepository;

  IsLiveWallpaperActiveUseCase(this._wallpaperSetterRepository);

  Future<Either<SetWallpaperFailure, bool>> execute() =>
      _wallpaperSetterRepository.isLiveWallpaperActive();
}
