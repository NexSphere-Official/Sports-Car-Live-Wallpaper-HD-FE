import '../../core/domain/models/wallpaper.dart';
import 'wallpaper_detail_initial_params.dart';

class WallpaperDetailState {
  final Wallpaper wallpaper;
  final bool showChrome;
  final bool isSettingWallpaper;

  const WallpaperDetailState({
    required this.wallpaper,
    required this.showChrome,
    required this.isSettingWallpaper,
  });

  factory WallpaperDetailState.initial({
    required WallpaperDetailInitialParams initialParams,
  }) => WallpaperDetailState(
    wallpaper: initialParams.wallpaper,
    showChrome: true,
    isSettingWallpaper: false,
  );

  WallpaperDetailState copyWith({
    Wallpaper? wallpaper,
    bool? showChrome,
    bool? isSettingWallpaper,
  }) => WallpaperDetailState(
    wallpaper: wallpaper ?? this.wallpaper,
    showChrome: showChrome ?? this.showChrome,
    isSettingWallpaper: isSettingWallpaper ?? this.isSettingWallpaper,
  );
}
