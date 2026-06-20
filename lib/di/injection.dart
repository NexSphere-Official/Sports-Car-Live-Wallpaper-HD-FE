import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/repositories/firebase_remote_config_repository.dart';
import '../core/data/repositories/flutter_cache_repository.dart';
import '../core/data/repositories/full_screen_ad_guard.dart';
import '../core/data/repositories/google_app_open_ad_manager.dart';
import '../core/data/repositories/google_mobile_ads_service.dart';
import '../core/data/repositories/platform_app_info_repository.dart';
import '../core/data/repositories/http_wallpaper_repository.dart';
import '../core/data/repositories/native_wallpaper_setter_repository.dart';
import '../core/data/repositories/shared_prefs_ad_policy_repository.dart';
import '../core/data/repositories/shared_prefs_favorites_repository.dart';
import '../core/data/repositories/shared_prefs_settings_repository.dart';
import '../core/data/repositories/ump_consent_manager.dart';
import '../core/domain/repositories/ad_policy_repository.dart';
import '../core/domain/repositories/ads_service.dart';
import '../core/domain/repositories/app_config_repository.dart';
import '../core/domain/repositories/app_open_ad_manager.dart';
import '../core/domain/repositories/app_info_repository.dart';
import '../core/domain/repositories/cache_repository.dart';
import '../core/domain/repositories/consent_manager.dart';
import '../core/domain/repositories/favorites_repository.dart';
import '../core/domain/repositories/settings_repository.dart';
import '../core/domain/repositories/wallpaper_repository.dart';
import '../core/domain/repositories/wallpaper_setter_repository.dart';
import '../core/domain/stores/ads/ads_store.dart';
import '../core/domain/stores/app_config/app_config_store.dart';
import '../core/domain/stores/favorites/favorites_store.dart';
import '../core/domain/stores/theme/theme_store.dart';
import '../core/domain/use_cases/gather_ads_consent_use_case.dart';
import '../core/domain/use_cases/get_app_config_use_case.dart';
import '../core/domain/use_cases/preload_rewarded_ad_use_case.dart';
import '../core/domain/use_cases/resolve_wallpaper_ad_slot_use_case.dart';
import '../core/domain/use_cases/show_apply_interstitial_use_case.dart';
import '../core/domain/use_cases/show_back_interstitial_use_case.dart';
import '../core/domain/use_cases/show_cold_start_app_open_ad_use_case.dart';
import '../core/domain/use_cases/suppress_next_app_open_ad_use_case.dart';
import '../core/domain/use_cases/unlock_wallpaper_use_case.dart';
import '../core/domain/use_cases/get_app_version_use_case.dart';
import '../core/domain/use_cases/get_favorites_use_case.dart';
import '../core/domain/use_cases/get_theme_mode_use_case.dart';
import '../core/domain/use_cases/get_privacy_policy_url_use_case.dart';
import '../core/domain/use_cases/is_privacy_options_required_use_case.dart';
import '../core/domain/use_cases/show_privacy_options_form_use_case.dart';
import '../core/domain/use_cases/get_wallpaper_use_case.dart';
import '../core/domain/use_cases/get_wallpapers_use_case.dart';
import '../core/domain/use_cases/rate_app_use_case.dart';
import '../core/domain/use_cases/share_app_use_case.dart';
import '../core/domain/use_cases/clear_cache_use_case.dart';
import '../core/domain/use_cases/clear_favorites_use_case.dart';
import '../core/domain/use_cases/set_theme_mode_use_case.dart';
import '../core/domain/use_cases/set_wallpaper_use_case.dart';
import '../core/domain/use_cases/toggle_favorite_use_case.dart';
import '../features/favorites/favorites_cubit.dart';
import '../features/favorites/favorites_initial_params.dart';
import '../features/favorites/favorites_navigator.dart';
import '../features/favorites/favorites_page.dart';
import '../features/home/home_cubit.dart';
import '../features/home/home_initial_params.dart';
import '../features/home/home_navigator.dart';
import '../features/home/home_page.dart';
import '../features/privacy_policy/privacy_policy_cubit.dart';
import '../features/privacy_policy/privacy_policy_initial_params.dart';
import '../features/privacy_policy/privacy_policy_navigator.dart';
import '../features/privacy_policy/privacy_policy_page.dart';
import '../features/settings/settings_cubit.dart';
import '../features/settings/settings_initial_params.dart';
import '../features/settings/settings_navigator.dart';
import '../features/settings/settings_page.dart';
import '../features/splash/splash_cubit.dart';
import '../features/splash/splash_initial_params.dart';
import '../features/splash/splash_navigator.dart';
import '../features/splash/splash_page.dart';
import '../features/wallpaper_detail/wallpaper_detail_cubit.dart';
import '../features/wallpaper_detail/wallpaper_detail_initial_params.dart';
import '../features/wallpaper_detail/wallpaper_detail_navigator.dart';
import '../features/wallpaper_detail/wallpaper_detail_page.dart';
import '../navigation/app_navigator.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // --- Infrastructure ---
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => AppNavigator());
  getIt.registerLazySingleton(() => FirebaseRemoteConfig.instance);

  // --- Global Stores ---
  getIt.registerLazySingleton(() => ThemeStore());
  getIt.registerLazySingleton(() => FavoritesStore());
  getIt.registerLazySingleton(() => AppConfigStore());
  getIt.registerLazySingleton(() => AdsStore());

  // --- Repositories ---
  getIt.registerLazySingleton<AppConfigRepository>(
    () => FirebaseRemoteConfigRepository(getIt()),
  );
  getIt.registerLazySingleton<WallpaperRepository>(
    () => HttpWallpaperRepository(getIt()),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => SharedPrefsFavoritesRepository(getIt()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SharedPrefsSettingsRepository(getIt()),
  );
  getIt.registerLazySingleton<WallpaperSetterRepository>(
    () => NativeWallpaperSetterRepository(getIt()),
  );
  getIt.registerLazySingleton<CacheRepository>(() => FlutterCacheRepository());
  getIt.registerLazySingleton<AppInfoRepository>(
    () => PlatformAppInfoRepository(),
  );

  // --- Ads ---
  getIt.registerLazySingleton(() => FullScreenAdGuard());
  getIt.registerLazySingleton<ConsentManager>(() => UmpConsentManager());
  getIt.registerLazySingleton<AdsService>(
    () => GoogleMobileAdsService(getIt()),
  );
  getIt.registerLazySingleton<AppOpenAdManager>(
    () => GoogleAppOpenAdManager(getIt()),
  );
  getIt.registerLazySingleton<AdPolicyRepository>(
    () => SharedPrefsAdPolicyRepository(getIt()),
  );

  // --- Use Cases ---
  getIt.registerSingleton(GetAppConfigUseCase(getIt(), getIt()));
  getIt.registerSingleton(
    GatherAdsConsentUseCase(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerSingleton(ShowColdStartAppOpenAdUseCase(getIt()));
  getIt.registerSingleton(SuppressNextAppOpenAdUseCase(getIt()));
  getIt.registerSingleton(
    ResolveWallpaperAdSlotUseCase(getIt(), getIt(), getIt()),
  );
  getIt.registerSingleton(UnlockWallpaperUseCase(getIt(), getIt(), getIt()));
  getIt.registerSingleton(
    PreloadRewardedAdUseCase(getIt(), getIt(), getIt()),
  );
  getIt.registerSingleton(ShowApplyInterstitialUseCase(getIt(), getIt()));
  getIt.registerSingleton(
    ShowBackInterstitialUseCase(getIt(), getIt(), getIt()),
  );
  getIt.registerSingleton(GetWallpapersUseCase(getIt(), getIt()));
  getIt.registerSingleton(GetWallpaperUseCase(getIt(), getIt()));
  getIt.registerSingleton(GetFavoritesUseCase(getIt(), getIt()));
  getIt.registerSingleton(ToggleFavoriteUseCase(getIt(), getIt()));
  getIt.registerSingleton(GetThemeModeUseCase(getIt(), getIt()));
  getIt.registerSingleton(SetThemeModeUseCase(getIt(), getIt()));
  getIt.registerSingleton(SetWallpaperUseCase(getIt()));
  getIt.registerSingleton(ClearCacheUseCase(getIt()));
  getIt.registerSingleton(ClearFavoritesUseCase(getIt(), getIt()));
  getIt.registerSingleton(GetAppVersionUseCase(getIt()));
  getIt.registerSingleton(ShareAppUseCase(getIt()));
  getIt.registerSingleton(RateAppUseCase(getIt()));
  getIt.registerSingleton(GetPrivacyPolicyUrlUseCase(getIt()));
  getIt.registerSingleton(IsPrivacyOptionsRequiredUseCase(getIt()));
  getIt.registerSingleton(ShowPrivacyOptionsFormUseCase(getIt()));

  // --- Feature: splash ---
  getIt.registerFactory(() => SplashNavigator(getIt()));
  getIt.registerFactoryParam<SplashCubit, SplashInitialParams, void>(
    (params, _) => SplashCubit(
      params,
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
  getIt.registerFactoryParam<SplashPage, SplashInitialParams, void>(
    (params, _) => SplashPage(cubit: getIt(param1: params)),
  );

  // --- Feature: home ---
  getIt.registerFactory(() => HomeNavigator(getIt()));
  getIt.registerFactoryParam<HomeCubit, HomeInitialParams, void>(
    (params, _) =>
        HomeCubit(params, getIt(), getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactoryParam<HomePage, HomeInitialParams, void>(
    (params, _) => HomePage(cubit: getIt(param1: params)),
  );

  // --- Feature: wallpaper_detail ---
  getIt.registerFactory(() => WallpaperDetailNavigator(getIt()));
  getIt.registerFactoryParam<
    WallpaperDetailCubit,
    WallpaperDetailInitialParams,
    void
  >(
    (params, _) => WallpaperDetailCubit(
      params,
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
  getIt.registerFactoryParam<
    WallpaperDetailPage,
    WallpaperDetailInitialParams,
    void
  >((params, _) => WallpaperDetailPage(cubit: getIt(param1: params)));

  // --- Feature: favorites ---
  getIt.registerFactory(() => FavoritesNavigator(getIt()));
  getIt.registerFactoryParam<FavoritesCubit, FavoritesInitialParams, void>(
    (params, _) =>
        FavoritesCubit(params, getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactoryParam<FavoritesPage, FavoritesInitialParams, void>(
    (params, _) => FavoritesPage(cubit: getIt(param1: params)),
  );

  // --- Feature: settings ---
  getIt.registerFactory(() => SettingsNavigator(getIt()));
  getIt.registerFactoryParam<SettingsCubit, SettingsInitialParams, void>(
    (params, _) => SettingsCubit(
      params,
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
  getIt.registerFactoryParam<SettingsPage, SettingsInitialParams, void>(
    (params, _) => SettingsPage(cubit: getIt(param1: params)),
  );

  // --- Feature: privacy_policy ---
  getIt.registerFactory(() => PrivacyPolicyNavigator(getIt()));
  getIt.registerFactoryParam<
    PrivacyPolicyCubit,
    PrivacyPolicyInitialParams,
    void
  >((params, _) => PrivacyPolicyCubit(params, getIt()));
  getIt.registerFactoryParam<
    PrivacyPolicyPage,
    PrivacyPolicyInitialParams,
    void
  >((params, _) => PrivacyPolicyPage(cubit: getIt(param1: params)));
}
