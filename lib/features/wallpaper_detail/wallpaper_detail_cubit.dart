import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/wallpaper_surface.dart';
import '../../core/domain/use_cases/resolve_wallpaper_ad_slot_use_case.dart';
import '../../core/domain/use_cases/set_wallpaper_use_case.dart';
import '../../core/domain/use_cases/show_apply_interstitial_use_case.dart';
import '../../core/domain/use_cases/suppress_next_app_open_ad_use_case.dart';
import '../../core/domain/use_cases/unlock_wallpaper_use_case.dart';
import 'wallpaper_detail_initial_params.dart';
import 'wallpaper_detail_navigator.dart';
import 'wallpaper_detail_state.dart';

class WallpaperDetailCubit extends Cubit<WallpaperDetailState> {
  final WallpaperDetailInitialParams initialParams;
  final SetWallpaperUseCase _setWallpaperUseCase;
  final ResolveWallpaperAdSlotUseCase _resolveWallpaperAdSlotUseCase;
  final UnlockWallpaperUseCase _unlockWallpaperUseCase;
  final ShowApplyInterstitialUseCase _showApplyInterstitialUseCase;
  final SuppressNextAppOpenAdUseCase _suppressNextAppOpenAdUseCase;
  final WallpaperDetailNavigator navigator;

  WallpaperDetailCubit(
    this.initialParams,
    this._setWallpaperUseCase,
    this._resolveWallpaperAdSlotUseCase,
    this._unlockWallpaperUseCase,
    this._showApplyInterstitialUseCase,
    this._suppressNextAppOpenAdUseCase,
    this.navigator,
  ) : super(WallpaperDetailState.initial(initialParams: initialParams));

  void onInit() => _resolveGate();

  Future<void> _resolveGate() async {
    final result = await _resolveWallpaperAdSlotUseCase.execute(
      state.wallpaper.id,
    );
    result.fold(
      // On failure, leave the default open gate so the wallpaper stays usable.
      (_) {},
      (gate) => emit(state.copyWith(adGate: gate)),
    );
  }

  /// "Unlock" action for locked (rewarded) wallpapers: watch a rewarded ad,
  /// then — once earned — apply immediately.
  Future<void> onTapUnlock() async {
    if (state.isPreparingAd || state.isSettingWallpaper) return;

    emit(state.copyWith(isPreparingAd: true));
    final result = await _unlockWallpaperUseCase.execute(state.wallpaper.id);
    emit(state.copyWith(isPreparingAd: false));

    await result.fold(
      (failure) async => navigator.showSnackbar(
        failure.displayableFailure().message,
        isError: true,
      ),
      (earned) async {
        if (!earned) {
          navigator.showSnackbar(
            'Watch the full ad to unlock this wallpaper.',
          );
          return;
        }
        emit(state.copyWith(adGate: state.adGate.copyWith(isUnlocked: true)));
        await _applyWallpaper();
      },
    );
  }

  /// "Set Wallpaper" action for unlocked/interstitial wallpapers. Interstitial
  /// wallpapers show an interstitial first; the apply proceeds regardless.
  Future<void> onTapApply() async {
    if (state.isPreparingAd || state.isSettingWallpaper) return;

    if (state.adGate.requiresInterstitial) {
      emit(state.copyWith(isPreparingAd: true));
      await _showApplyInterstitialUseCase.execute();
      emit(state.copyWith(isPreparingAd: false));
    }

    await _applyWallpaper();
  }

  Future<void> _applyWallpaper() async {
    // Live wallpapers open the system live-wallpaper preview, where the user
    // confirms. Launching the preview is NOT the same as applying it, so we
    // can't claim success here — instead we flag the pending result and show a
    // popup once the user returns to this screen (see [onAppResumed]).
    if (state.wallpaper.isLive) {
      emit(state.copyWith(isSettingWallpaper: true));
      // The live preview backgrounds the app; don't let the return foreground
      // trigger an app-open ad over the "wallpaper ready" popup.
      await _suppressNextAppOpenAdUseCase.execute();
      final result = await _setWallpaperUseCase.execute(state.wallpaper);
      emit(state.copyWith(isSettingWallpaper: false));
      result.fold(
        (failure) => navigator.showSnackbar(
          failure.displayableFailure().message,
          isError: true,
        ),
        (_) => emit(state.copyWith(awaitingLiveResult: true)),
      );
      return;
    }

    // Static wallpapers: ask where to apply, then set silently.
    final surface = await navigator.askWallpaperSurface();
    if (surface == null) return;

    emit(state.copyWith(isSettingWallpaper: true));
    final result = await _setWallpaperUseCase.execute(
      state.wallpaper,
      surface: surface,
    );
    emit(state.copyWith(isSettingWallpaper: false));
    result.fold(
      (failure) => navigator.showSnackbar(
        failure.displayableFailure().message,
        isError: true,
      ),
      (_) => navigator.showSnackbar(
        'Wallpaper applied to your ${_surfaceLabel(surface)}.',
      ),
    );
  }

  /// The app returned to the foreground. If we'd opened the live-wallpaper
  /// preview, confirm the outcome with a popup now that the user is back.
  void onAppResumed() {
    if (!state.awaitingLiveResult) return;
    emit(state.copyWith(awaitingLiveResult: false));
    navigator.showInfo(
      'Live wallpaper',
      "Your live wallpaper is ready. If you confirmed it in the preview, "
          "it's now set on your device.",
    );
  }

  String _surfaceLabel(WallpaperSurface surface) {
    switch (surface) {
      case WallpaperSurface.home:
        return 'home screen';
      case WallpaperSurface.lock:
        return 'lock screen';
      case WallpaperSurface.both:
        return 'home & lock screen';
    }
  }

  /// Enter immersive preview — hide all UI chrome.
  void onTapPreview() => emit(state.copyWith(showChrome: false));

  /// Tapping the wallpaper toggles the chrome back on/off.
  void onToggleChrome() => emit(state.copyWith(showChrome: !state.showChrome));

  void onTapBack() => navigator.close();
}
