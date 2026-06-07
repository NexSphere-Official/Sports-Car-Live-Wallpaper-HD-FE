import 'app_navigator.dart';

mixin CloseRoute {
  void close() => appNavigator.close();
  AppNavigator get appNavigator;
}
