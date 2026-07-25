import 'package:equatable/equatable.dart';

/// The kind of full-screen ad gating a wallpaper's apply flow. Wallpapers are
/// assigned one of these (per the [AdsConfig.unlockPattern]) the first time
/// their detail page opens, and the two are mutually exclusive per wallpaper.
enum AdSlotType {
  /// Wallpaper is locked until the user watches a rewarded ad once. The unlock
  /// then persists and the wallpaper applies freely afterwards.
  rewarded,

  /// Wallpaper applies after an interstitial ad (shown each apply, throttled by
  /// [InterstitialAdConfig.cooldown]).
  interstitial;

  static AdSlotType fromKey(String key) {
    switch (key.trim().toLowerCase()) {
      case 'interstitial':
        return AdSlotType.interstitial;
      case 'rewarded':
      default:
        return AdSlotType.rewarded;
    }
  }
}

/// Remotely-configurable ad settings, nested under the `ads` object of the
/// Remote Config `app_config` value. Every unit id, toggle, interval and
/// cooldown lives here so ads can be tuned or disabled without an app release.
///
/// [AdsConfig.empty] holds the built-in production defaults used when Remote
/// Config has not supplied a value; live config from the console overlays these.
class AdsConfig extends Equatable {
  /// Master kill switch. When false, no ads of any kind are requested or shown.
  final bool enabled;
  final AppOpenAdConfig appOpen;
  final InterstitialAdConfig interstitial;
  final RewardedAdConfig rewarded;
  final NativeAdConfig native;

  /// Repeating sequence assigning each newly-opened wallpaper an [AdSlotType].
  /// e.g. `[rewarded, interstitial, rewarded, interstitial, rewarded]`.
  final List<AdSlotType> unlockPattern;

  const AdsConfig({
    required this.enabled,
    required this.appOpen,
    required this.interstitial,
    required this.rewarded,
    required this.native,
    required this.unlockPattern,
  });

  /// Default ad configuration (production Android ad unit ids).
  factory AdsConfig.empty() => AdsConfig(
    enabled: true,
    appOpen: AppOpenAdConfig.empty(),
    interstitial: InterstitialAdConfig.empty(),
    rewarded: RewardedAdConfig.empty(),
    native: NativeAdConfig.empty(),
    unlockPattern: const [
      AdSlotType.rewarded,
      AdSlotType.interstitial,
      AdSlotType.rewarded,
      AdSlotType.interstitial,
      AdSlotType.rewarded,
    ],
  );

  AdsConfig copyWith({
    bool? enabled,
    AppOpenAdConfig? appOpen,
    InterstitialAdConfig? interstitial,
    RewardedAdConfig? rewarded,
    NativeAdConfig? native,
    List<AdSlotType>? unlockPattern,
  }) => AdsConfig(
    enabled: enabled ?? this.enabled,
    appOpen: appOpen ?? this.appOpen,
    interstitial: interstitial ?? this.interstitial,
    rewarded: rewarded ?? this.rewarded,
    native: native ?? this.native,
    unlockPattern: unlockPattern ?? this.unlockPattern,
  );

  /// The [AdSlotType] for the wallpaper at the given zero-based encounter index.
  AdSlotType slotTypeForIndex(int index) {
    if (unlockPattern.isEmpty) return AdSlotType.rewarded;
    return unlockPattern[index % unlockPattern.length];
  }

  @override
  List<Object?> get props => [
    enabled,
    appOpen,
    interstitial,
    rewarded,
    native,
    unlockPattern,
  ];
}

class AppOpenAdConfig extends Equatable {
  final bool enabled;
  final String adUnitId;

  /// Show an app-open ad on cold start (after splash + consent + SDK init).
  final bool onColdStart;

  /// Show an app-open ad when the app returns from the background.
  final bool onResume;

  /// Minimum gap between two resume app-open ads.
  final Duration resumeCooldown;

  /// How long the app must actually have been in the background before a
  /// return counts as a resume. Filters momentary trips out to a share sheet,
  /// permission dialog or wallpaper preview, which a user experiences as never
  /// having left the app at all.
  final Duration minBackgroundDuration;

  /// How long an explicit [AppOpenAdManager.suppressNextResume] request stays
  /// armed. Bounded so a suppression whose expected background trip never
  /// happened can't swallow an unrelated resume later on.
  final Duration suppressResumeWindow;

  /// How long to wait for an app-open ad to load before giving up so launch is
  /// never blocked.
  final Duration loadTimeout;

  const AppOpenAdConfig({
    required this.enabled,
    required this.adUnitId,
    required this.onColdStart,
    required this.onResume,
    required this.resumeCooldown,
    required this.minBackgroundDuration,
    required this.suppressResumeWindow,
    required this.loadTimeout,
  });

  factory AppOpenAdConfig.empty() => const AppOpenAdConfig(
    enabled: true,
    adUnitId: 'ca-app-pub-3891353847321850/8258418489',
    onColdStart: true,
    onResume: true,
    resumeCooldown: Duration(seconds: 30),
    minBackgroundDuration: Duration(seconds: 10),
    suppressResumeWindow: Duration(minutes: 5),
    loadTimeout: Duration(seconds: 8),
  );

  bool get isUsable => enabled && adUnitId.isNotEmpty;

  AppOpenAdConfig copyWith({
    bool? enabled,
    String? adUnitId,
    bool? onColdStart,
    bool? onResume,
    Duration? resumeCooldown,
    Duration? minBackgroundDuration,
    Duration? suppressResumeWindow,
    Duration? loadTimeout,
  }) => AppOpenAdConfig(
    enabled: enabled ?? this.enabled,
    adUnitId: adUnitId ?? this.adUnitId,
    onColdStart: onColdStart ?? this.onColdStart,
    onResume: onResume ?? this.onResume,
    resumeCooldown: resumeCooldown ?? this.resumeCooldown,
    minBackgroundDuration:
        minBackgroundDuration ?? this.minBackgroundDuration,
    suppressResumeWindow: suppressResumeWindow ?? this.suppressResumeWindow,
    loadTimeout: loadTimeout ?? this.loadTimeout,
  );

  @override
  List<Object?> get props => [
    enabled,
    adUnitId,
    onColdStart,
    onResume,
    resumeCooldown,
    minBackgroundDuration,
    suppressResumeWindow,
    loadTimeout,
  ];
}

/// Interstitials are shown at exactly one point: applying a wallpaper whose
/// assigned slot is [AdSlotType.interstitial]. The old "back from Saved"
/// placement was removed — it could only work by preloading on entry to a
/// screen most visitors left by tapping through rather than backing out, so it
/// filled roughly fourteen requests for every ad it managed to display.
class InterstitialAdConfig extends Equatable {
  final bool enabled;
  final String adUnitId;

  /// Minimum gap between any two full-screen ads (throttles stacking).
  final Duration cooldown;

  const InterstitialAdConfig({
    required this.enabled,
    required this.adUnitId,
    required this.cooldown,
  });

  factory InterstitialAdConfig.empty() => const InterstitialAdConfig(
    enabled: true,
    adUnitId: 'ca-app-pub-3891353847321850/4319173471',
    cooldown: Duration(seconds: 15),
  );

  bool get isUsable => enabled && adUnitId.isNotEmpty;

  InterstitialAdConfig copyWith({
    bool? enabled,
    String? adUnitId,
    Duration? cooldown,
  }) => InterstitialAdConfig(
    enabled: enabled ?? this.enabled,
    adUnitId: adUnitId ?? this.adUnitId,
    cooldown: cooldown ?? this.cooldown,
  );

  @override
  List<Object?> get props => [enabled, adUnitId, cooldown];
}

class RewardedAdConfig extends Equatable {
  final bool enabled;
  final String adUnitId;

  const RewardedAdConfig({required this.enabled, required this.adUnitId});

  factory RewardedAdConfig.empty() => const RewardedAdConfig(
    enabled: true,
    adUnitId: 'ca-app-pub-3891353847321850/8582118041',
  );

  bool get isUsable => enabled && adUnitId.isNotEmpty;

  RewardedAdConfig copyWith({bool? enabled, String? adUnitId}) =>
      RewardedAdConfig(
        enabled: enabled ?? this.enabled,
        adUnitId: adUnitId ?? this.adUnitId,
      );

  @override
  List<Object?> get props => [enabled, adUnitId];
}

class NativeAdConfig extends Equatable {
  final bool enabled;
  final String adUnitId;

  /// Insert a native ad card after every N wallpapers in the grid.
  final int gridInterval;

  const NativeAdConfig({
    required this.enabled,
    required this.adUnitId,
    required this.gridInterval,
  });

  factory NativeAdConfig.empty() => const NativeAdConfig(
    enabled: true,
    adUnitId: 'ca-app-pub-3891353847321850/5006824793',
    gridInterval: 8,
  );

  bool get isUsable => enabled && adUnitId.isNotEmpty && gridInterval > 0;

  NativeAdConfig copyWith({bool? enabled, String? adUnitId, int? gridInterval}) =>
      NativeAdConfig(
        enabled: enabled ?? this.enabled,
        adUnitId: adUnitId ?? this.adUnitId,
        gridInterval: gridInterval ?? this.gridInterval,
      );

  @override
  List<Object?> get props => [enabled, adUnitId, gridInterval];
}
