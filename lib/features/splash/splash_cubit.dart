import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/use_cases/get_app_config_use_case.dart';
import '../../core/domain/use_cases/get_favorites_use_case.dart';
import '../../core/domain/use_cases/get_theme_mode_use_case.dart';
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
  final GetThemeModeUseCase _getThemeModeUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;
  final SplashNavigator navigator;

  SplashCubit(
    this.initialParams,
    this._getAppConfigUseCase,
    this._getThemeModeUseCase,
    this._getFavoritesUseCase,
    this.navigator,
  ) : super(SplashState.initial(initialParams: initialParams));

  static const _minimumOnScreen = Duration(milliseconds: 2800);

  Future<void> onInit() async {
    final startedAt = DateTime.now();

    _set(0.08, 'IGNITION');

    // Remote config first — everything downstream depends on the API base URL.
    await _getAppConfigUseCase.execute();
    _set(0.45, 'FETCHING CONFIG');

    await _getThemeModeUseCase.execute();
    _set(0.70, 'TUNING THEME');

    await _getFavoritesUseCase.execute();
    _set(0.92, 'LOADING GARAGE');

    // Hold the splash for a beat so the intro reads as intentional, not a stall.
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minimumOnScreen) {
      await Future.delayed(_minimumOnScreen - elapsed);
    }

    _set(1.0, 'READY');
    await Future.delayed(const Duration(milliseconds: 450));

    if (isClosed) return;
    navigator.replaceWithHome(const HomeInitialParams());
  }

  void _set(double progress, String label) {
    if (isClosed) return;
    emit(state.copyWith(progress: progress, statusLabel: label));
  }
}
