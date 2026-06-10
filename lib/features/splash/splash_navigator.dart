import 'package:get_it/get_it.dart';
import '../home/home_initial_params.dart';
import '../home/home_navigator.dart';
import '../home/home_page.dart';
import 'splash_initial_params.dart';
import 'splash_page.dart';
import '../../navigation/app_navigator.dart';
import '../../navigation/close_route.dart';
import '../../navigation/error_dialog_route.dart';

class SplashNavigator with CloseRoute, ErrorDialogRoute, HomeRoute {
  SplashNavigator(this.appNavigator);

  @override
  final AppNavigator appNavigator;

  /// Swap the splash for home with a cross-fade, dropping it from the back
  /// stack so the system back button can never return to the intro.
  Future<void> replaceWithHome(HomeInitialParams initialParams) {
    return appNavigator.pushReplacement(
      fadeInRoute(
        GetIt.instance<HomePage>(param1: initialParams),
        durationMillis: 600,
      ),
    );
  }
}

mixin SplashRoute {
  Future<void> openSplash(SplashInitialParams initialParams) {
    return appNavigator.push(
      materialRoute(GetIt.instance<SplashPage>(param1: initialParams)),
    );
  }

  AppNavigator get appNavigator;
}
