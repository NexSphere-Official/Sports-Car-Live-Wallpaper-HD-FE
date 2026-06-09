import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/domain/models/app_theme_mode.dart';
import 'core/domain/stores/theme/theme_state.dart';
import 'core/domain/stores/theme/theme_store.dart';
import 'core/domain/use_cases/get_app_config_use_case.dart';
import 'core/domain/use_cases/get_favorites_use_case.dart';
import 'core/domain/use_cases/get_theme_mode_use_case.dart';
import 'di/injection.dart' as di;
import 'features/home/home_cubit.dart';
import 'features/home/home_initial_params.dart';
import 'features/home/home_page.dart';
import 'firebase_options.dart';
import 'navigation/app_navigator.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  // Resolve the API base URL from Remote Config before anything fetches data.
  await GetIt.instance<GetAppConfigUseCase>().execute();
  await GetIt.instance<GetThemeModeUseCase>().execute();
  await GetIt.instance<GetFavoritesUseCase>().execute();
  runApp(const SportsCarApp());
}

class SportsCarApp extends StatefulWidget {
  const SportsCarApp({super.key});

  @override
  State<SportsCarApp> createState() => _SportsCarAppState();
}

class _SportsCarAppState extends State<SportsCarApp> {
  // Create the cubit once so loaded wallpapers survive theme changes, while
  // still building a fresh HomePage widget on each rebuild so the whole page
  // (including the pinned filter header) repaints with the active theme.
  final HomeCubit _homeCubit = GetIt.instance<HomeCubit>(
    param1: const HomeInitialParams(),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeStore, ThemeStoreState>(
      bloc: GetIt.instance<ThemeStore>(),
      builder: (context, state) {
        return MaterialApp(
          title: 'Sports Car Live Wallpaper 4K',
          debugShowCheckedModeBanner: false,
          navigatorKey: AppNavigator.navigatorKey,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeMode(state.mode),
          home: HomePage(cubit: _homeCubit),
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
