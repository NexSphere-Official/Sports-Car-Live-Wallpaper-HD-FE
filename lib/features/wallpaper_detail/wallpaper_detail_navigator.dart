import 'package:get_it/get_it.dart';
import 'wallpaper_detail_initial_params.dart';
import 'wallpaper_detail_page.dart';
import '../../navigation/app_navigator.dart';
import '../../navigation/close_route.dart';
import '../../navigation/error_dialog_route.dart';
import '../../navigation/info_dialog_route.dart';
import '../../navigation/wallpaper_surface_sheet_route.dart';

class WallpaperDetailNavigator
    with
        CloseRoute,
        ErrorDialogRoute,
        InfoDialogRoute,
        WallpaperSurfaceSheetRoute {
  WallpaperDetailNavigator(this.appNavigator);

  @override
  final AppNavigator appNavigator;
}

mixin WallpaperDetailRoute {
  Future<void> openWallpaperDetail(WallpaperDetailInitialParams initialParams) {
    return appNavigator.push(
      slideBottomRoute(
        GetIt.instance<WallpaperDetailPage>(param1: initialParams),
      ),
    );
  }

  AppNavigator get appNavigator;
}
