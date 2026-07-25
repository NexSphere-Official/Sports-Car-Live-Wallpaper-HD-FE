import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/wallpaper_surface.dart';
import '../../core/domain/use_cases/is_live_wallpaper_active_use_case.dart';
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
  final IsLiveWallpaperActiveUseCase _isLiveWallpaperActiveUseCase;
  final SuppressNextAppOpenAdUseCase _suppressNextAppOpenAdUseCase;
  final WallpaperDetailNavigator navigator;

  WallpaperDetailCubit(
    this.initialParams,
    this._setWallpaperUseCase,
    this._resolveWallpaperAdSlotUseCase,
    this._unlockWallpaperUseCase,
    this._showApplyInterstitialUseCase,
    this._isLiveWallpaperActiveUseCase,
    this._suppressNextAppOpenAdUseCase,
    this.navigator,
  ) : super(WallpaperDetailState.initial(initialParams: initialParams));

  void onInit() => _resolveGate();

  Future<void> _resolveGate() async {
    final result = await _resolveWallpaperAdSlotUseCase.execute(
      state.wallpaper.id,
    );
    // On failure, leave the default open gate so the wallpaper stays usable.
    final gate = result.fold((_) => null, (gate) => gate);
    emit(
      state.copyWith(
        adGate: gate ?? state.adGate,
        isResolvingGate: false,
      ),
    );
    // No rewarded preload here, deliberately. Opening a locked wallpaper is
    // not intent to watch an ad — most opens never reach "Unlock", so
    // preloading here bought roughly eight ads for every one displayed. The
    // load now happens on the tap, behind [isPreparingAd].
  }

  /// "Unlock" action for locked (rewarded) wallpapers: watch a rewarded ad,
  /// then — once earned — apply immediately.
  Future<void> onTapUnlock() async {
    if (state.isBusy) return;

    // The "Watch to unlock" button is itself the opt-in/value-exchange
    // disclosure, so go straight to the rewarded ad.
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
    // Includes isResolvingGate: until the slot is known the gate reads "open",
    // so acting on it would apply the wallpaper for free and skip the ad the
    // pattern had assigned it.
    if (state.isBusy) return;

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

  /// The app returned to the foreground after the live-wallpaper preview. Show a
  /// success snackbar only if our live wallpaper is now actually active; if the
  /// user backed out without applying it, show nothing.
  Future<void> onAppResumed() async {
    if (!state.awaitingLiveResult) return;
    emit(state.copyWith(awaitingLiveResult: false));

    final result = await _isLiveWallpaperActiveUseCase.execute();
    result.fold(
      // Couldn't determine the outcome — stay silent rather than guess.
      (_) {},
      (isActive) {
        if (isActive) {
          navigator.showSnackbar('Live wallpaper applied to your device.');
        }
      },
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
