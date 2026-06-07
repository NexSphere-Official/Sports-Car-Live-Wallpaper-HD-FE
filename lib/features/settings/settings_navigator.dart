import 'package:get_it/get_it.dart';
import 'settings_initial_params.dart';
import 'settings_page.dart';
import '../../navigation/app_navigator.dart';
import '../../navigation/close_route.dart';
import '../../navigation/error_dialog_route.dart';
import '../../navigation/info_dialog_route.dart';
import '../../navigation/confirm_dialog_route.dart';

class SettingsNavigator
    with CloseRoute, ErrorDialogRoute, InfoDialogRoute, ConfirmDialogRoute {
  SettingsNavigator(this.appNavigator);

  @override
  final AppNavigator appNavigator;
}

mixin SettingsRoute {
  Future<void> openSettings(SettingsInitialParams initialParams) {
    return appNavigator.push(
      materialRoute(GetIt.instance<SettingsPage>(param1: initialParams)),
    );
  }

  AppNavigator get appNavigator;
}
