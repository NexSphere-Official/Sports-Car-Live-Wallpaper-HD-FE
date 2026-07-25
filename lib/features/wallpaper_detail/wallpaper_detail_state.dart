import '../../core/domain/models/wallpaper.dart';
import '../../core/domain/models/wallpaper_ad_gate.dart';
import 'wallpaper_detail_initial_params.dart';

class WallpaperDetailState {
  final Wallpaper wallpaper;
  final bool showChrome;
  final bool isSettingWallpaper;

  /// True while the native live-wallpaper preview is open and we're waiting for
  /// the user to return so we can confirm the outcome with a popup.
  final bool awaitingLiveResult;

  /// The wallpaper's ad gate (locked/interstitial/open). Defaults to open until
  /// resolved so the UI never blocks before the policy is known — which is why
  /// the primary action must stay disabled while [isResolvingGate] is true.
  final WallpaperAdGate adGate;

  /// True until [adGate] reflects the wallpaper's persisted slot. Acting on the
  /// permissive default before then would apply the wallpaper with no ad.
  final bool isResolvingGate;

  /// True while a rewarded/interstitial ad is loading or showing.
  final bool isPreparingAd;

  const WallpaperDetailState({
    required this.wallpaper,
    required this.showChrome,
    required this.isSettingWallpaper,
    required this.awaitingLiveResult,
    required this.adGate,
    required this.isResolvingGate,
    required this.isPreparingAd,
  });

  factory WallpaperDetailState.initial({
    required WallpaperDetailInitialParams initialParams,
  }) => WallpaperDetailState(
    wallpaper: initialParams.wallpaper,
    showChrome: true,
    isSettingWallpaper: false,
    awaitingLiveResult: false,
    adGate: WallpaperAdGate.empty(),
    isResolvingGate: true,
    isPreparingAd: false,
  );

  /// Whether the primary action should present as "Unlock" rather than "Set".
  bool get isLocked => adGate.isLocked;

  /// The primary action is unavailable: an ad or apply is already running, or
  /// we don't yet know which gate applies.
  bool get isBusy => isResolvingGate || isPreparingAd || isSettingWallpaper;

  WallpaperDetailState copyWith({
    Wallpaper? wallpaper,
    bool? showChrome,
    bool? isSettingWallpaper,
    bool? awaitingLiveResult,
    WallpaperAdGate? adGate,
    bool? isResolvingGate,
    bool? isPreparingAd,
  }) => WallpaperDetailState(
    wallpaper: wallpaper ?? this.wallpaper,
    showChrome: showChrome ?? this.showChrome,
    isSettingWallpaper: isSettingWallpaper ?? this.isSettingWallpaper,
    awaitingLiveResult: awaitingLiveResult ?? this.awaitingLiveResult,
    adGate: adGate ?? this.adGate,
    isResolvingGate: isResolvingGate ?? this.isResolvingGate,
    isPreparingAd: isPreparingAd ?? this.isPreparingAd,
  );
}
