import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/use_cases/gather_ads_consent_use_case.dart';
import '../../core/domain/use_cases/get_app_config_use_case.dart';
import '../../core/domain/use_cases/get_favorites_use_case.dart';
import '../../core/domain/use_cases/get_theme_mode_use_case.dart';
import '../../core/domain/use_cases/show_cold_start_app_open_ad_use_case.dart';
import '../home/home_initial_params.dart';
import 'splash_initial_params.dart';
import 'splash_navigator.dart';
import 'splash_state.dart';

/// Owns app bootstrap: pulls the remote config (API base URL), persisted theme
/// and favorites while the splash plays, then replaces itself with home. A
/// minimum on-screen duration keeps the intro from flashing on fast networks.
class SplashCubit extends Cubit<SplashState> {
  final SplashInitialParams initialParams;
  final GetAppConfigUseCase _getAppConfigUseCase;
  final GatherAdsConsentUseCase _gatherAdsConsentUseCase;
  final ShowColdStartAppOpenAdUseCase _showColdStartAppOpenAdUseCase;
  final GetThemeModeUseCase _getThemeModeUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;
  final SplashNavigator navigator;

  SplashCubit(
    this.initialParams,
    this._getAppConfigUseCase,
    this._gatherAdsConsentUseCase,
    this._showColdStartAppOpenAdUseCase,
    this._getThemeModeUseCase,
    this._getFavoritesUseCase,
    this.navigator,
  ) : super(SplashState.initial(initialParams: initialParams));

  static const _minimumOnScreen = Duration(milliseconds: 2800);

  Future<void> onInit() async {
    final startedAt = DateTime.now();

    _set(0.08, 'IGNITION');

    // Remote config first — everything downstream depends on the API base URL
    // and the ads configuration read by the consent step below.
    await _getAppConfigUseCase.execute();
    _set(0.40, 'FETCHING CONFIG');

    // Gather UMP consent and, if permitted, initialize the ads SDK (and begin
    // preloading the app-open ad). Never blocks launch — failures resolve
    // quietly.
    final adsResult = await _gatherAdsConsentUseCase.execute();
    final adsReady = adsResult.getOrElse(() => false);
    _set(0.60, 'PREPARING');

    await _getThemeModeUseCase.execute();
    _set(0.78, 'TUNING THEME');

    await _getFavoritesUseCase.execute();
    _set(0.92, 'LOADING GARAGE');

    // Hold the splash for a beat so the intro reads as intentional, not a stall.
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minimumOnScreen) {
      await Future.delayed(_minimumOnScreen - elapsed);
    }

    _set(1.0, 'READY');
    await Future.delayed(const Duration(milliseconds: 450));

    // Show the cold-start app-open ad (over the splash) before handing off to
    // home. No-op if ads aren't ready or none loaded within the budget.
    if (adsReady) await _showColdStartAppOpenAdUseCase.execute();

    if (isClosed) return;
    navigator.replaceWithHome(const HomeInitialParams());
  }

  void _set(double progress, String label) {
    if (isClosed) return;
    emit(state.copyWith(progress: progress, statusLabel: label));
  }
}
