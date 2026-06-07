import 'package:get_it/get_it.dart';
import 'favorites_initial_params.dart';
import 'favorites_page.dart';
import '../wallpaper_detail/wallpaper_detail_navigator.dart';
import '../../navigation/app_navigator.dart';
import '../../navigation/close_route.dart';
import '../../navigation/error_dialog_route.dart';

class FavoritesNavigator
    with CloseRoute, ErrorDialogRoute, WallpaperDetailRoute {
  FavoritesNavigator(this.appNavigator);

  @override
  final AppNavigator appNavigator;
}

mixin FavoritesRoute {
  Future<void> openFavorites(FavoritesInitialParams initialParams) {
    return appNavigator.push(
      materialRoute(GetIt.instance<FavoritesPage>(param1: initialParams)),
    );
  }

  AppNavigator get appNavigator;
}
