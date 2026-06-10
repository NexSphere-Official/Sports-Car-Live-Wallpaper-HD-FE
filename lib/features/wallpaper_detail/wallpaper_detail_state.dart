import '../../core/domain/models/wallpaper.dart';
import 'wallpaper_detail_initial_params.dart';

class WallpaperDetailState {
  final Wallpaper wallpaper;
  final bool showChrome;
  final bool isSettingWallpaper;

  /// True while the native live-wallpaper preview is open and we're waiting for
  /// the user to return so we can confirm the outcome with a popup.
  final bool awaitingLiveResult;

  const WallpaperDetailState({
    required this.wallpaper,
    required this.showChrome,
    required this.isSettingWallpaper,
    required this.awaitingLiveResult,
  });

  factory WallpaperDetailState.initial({
    required WallpaperDetailInitialParams initialParams,
  }) => WallpaperDetailState(
    wallpaper: initialParams.wallpaper,
    showChrome: true,
    isSettingWallpaper: false,
    awaitingLiveResult: false,
  );

  WallpaperDetailState copyWith({
    Wallpaper? wallpaper,
    bool? showChrome,
    bool? isSettingWallpaper,
    bool? awaitingLiveResult,
  }) => WallpaperDetailState(
    wallpaper: wallpaper ?? this.wallpaper,
    showChrome: showChrome ?? this.showChrome,
    isSettingWallpaper: isSettingWallpaper ?? this.isSettingWallpaper,
    awaitingLiveResult: awaitingLiveResult ?? this.awaitingLiveResult,
  );
}
