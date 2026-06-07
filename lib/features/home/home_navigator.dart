import 'package:get_it/get_it.dart';
import '../favorites/favorites_navigator.dart';
import 'home_initial_params.dart';
import 'home_page.dart';
import '../settings/settings_navigator.dart';
import '../wallpaper_detail/wallpaper_detail_navigator.dart';
import '../../navigation/app_navigator.dart';
import '../../navigation/close_route.dart';
import '../../navigation/error_dialog_route.dart';

class HomeNavigator
    with
        CloseRoute,
        ErrorDialogRoute,
        WallpaperDetailRoute,
        FavoritesRoute,
        SettingsRoute {
  HomeNavigator(this.appNavigator);

  @override
  final AppNavigator appNavigator;
}

mixin HomeRoute {
  Future<void> openHome(HomeInitialParams initialParams) {
    return appNavigator.push(
      materialRoute(GetIt.instance<HomePage>(param1: initialParams)),
    );
  }

  AppNavigator get appNavigator;
}
