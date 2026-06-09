import 'package:get_it/get_it.dart';
import 'privacy_policy_initial_params.dart';
import 'privacy_policy_page.dart';
import '../../navigation/app_navigator.dart';
import '../../navigation/close_route.dart';
import '../../navigation/error_dialog_route.dart';

class PrivacyPolicyNavigator with CloseRoute, ErrorDialogRoute {
  PrivacyPolicyNavigator(this.appNavigator);

  @override
  final AppNavigator appNavigator;
}

mixin PrivacyPolicyRoute {
  Future<void> openPrivacyPolicy(PrivacyPolicyInitialParams initialParams) {
    return appNavigator.push(
      materialRoute(GetIt.instance<PrivacyPolicyPage>(param1: initialParams)),
    );
  }

  AppNavigator get appNavigator;
}
