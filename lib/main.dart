import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/domain/models/app_theme_mode.dart';
import 'core/domain/stores/theme/theme_state.dart';
import 'core/domain/stores/theme/theme_store.dart';
import 'di/injection.dart' as di;
import 'features/splash/splash_initial_params.dart';
import 'features/splash/splash_page.dart';
import 'firebase_options.dart';
import 'navigation/app_navigator.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  // Remote config, theme and favorites are loaded by the splash screen so the
  // user sees branded loading progress instead of a frozen launch image.
  runApp(const SportsCarApp());
}

class SportsCarApp extends StatelessWidget {
  const SportsCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeStore, ThemeStoreState>(
      bloc: GetIt.instance<ThemeStore>(),
      builder: (context, state) {
        return MaterialApp(
          title: 'Live Sports Car Wallpaper 4K',
          debugShowCheckedModeBanner: false,
          navigatorKey: AppNavigator.navigatorKey,
          scaffoldMessengerKey: AppNavigator.scaffoldMessengerKey,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeMode(state.mode),
          home: GetIt.instance<SplashPage>(
            param1: const SplashInitialParams(),
          ),
        );
      },
    );
  }

  ThemeMode _themeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
