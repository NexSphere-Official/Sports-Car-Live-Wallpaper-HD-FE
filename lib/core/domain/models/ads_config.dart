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
/// [AdsConfig.empty] holds the built-in defaults (Google's Android test ad
/// setup) used when Remote Config has not supplied a value; live config from
/// the console overlays these.
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

  /// Default ad configuration (Google's official Android test ad unit ids).
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

  /// How long to wait for an app-open ad to load before giving up so launch is
  /// never blocked.
  final Duration loadTimeout;

  const AppOpenAdConfig({
    required this.enabled,
    required this.adUnitId,
    required this.onColdStart,
    required this.onResume,
    required this.resumeCooldown,
    required this.loadTimeout,
  });

  factory AppOpenAdConfig.empty() => const AppOpenAdConfig(
    enabled: true,
    adUnitId: 'ca-app-pub-3940256099942544/9257395921',
    onColdStart: true,
    onResume: true,
    resumeCooldown: Duration(seconds: 30),
    loadTimeout: Duration(seconds: 8),
  );

  bool get isUsable => enabled && adUnitId.isNotEmpty;

  AppOpenAdConfig copyWith({
    bool? enabled,
    String? adUnitId,
    bool? onColdStart,
    bool? onResume,
    Duration? resumeCooldown,
    Duration? loadTimeout,
  }) => AppOpenAdConfig(
    enabled: enabled ?? this.enabled,
    adUnitId: adUnitId ?? this.adUnitId,
    onColdStart: onColdStart ?? this.onColdStart,
    onResume: onResume ?? this.onResume,
    resumeCooldown: resumeCooldown ?? this.resumeCooldown,
    loadTimeout: loadTimeout ?? this.loadTimeout,
  );

  @override
  List<Object?> get props => [
    enabled,
    adUnitId,
    onColdStart,
    onResume,
    resumeCooldown,
    loadTimeout,
  ];
}

class InterstitialAdConfig extends Equatable {
  final bool enabled;
  final String adUnitId;

  /// Show an interstitial when the user navigates back from the Saved page.
  final bool onBackFromSaved;

  /// Minimum gap between any two full-screen ads (throttles stacking).
  final Duration cooldown;

  const InterstitialAdConfig({
    required this.enabled,
    required this.adUnitId,
    required this.onBackFromSaved,
    required this.cooldown,
  });

  factory InterstitialAdConfig.empty() => const InterstitialAdConfig(
    enabled: true,
    adUnitId: 'ca-app-pub-3940256099942544/1033173712',
    onBackFromSaved: true,
    cooldown: Duration(seconds: 15),
  );

  bool get isUsable => enabled && adUnitId.isNotEmpty;

  InterstitialAdConfig copyWith({
    bool? enabled,
    String? adUnitId,
    bool? onBackFromSaved,
    Duration? cooldown,
  }) => InterstitialAdConfig(
    enabled: enabled ?? this.enabled,
    adUnitId: adUnitId ?? this.adUnitId,
    onBackFromSaved: onBackFromSaved ?? this.onBackFromSaved,
    cooldown: cooldown ?? this.cooldown,
  );

  @override
  List<Object?> get props => [enabled, adUnitId, onBackFromSaved, cooldown];
}

class RewardedAdConfig extends Equatable {
  final bool enabled;
  final String adUnitId;

  const RewardedAdConfig({required this.enabled, required this.adUnitId});

  factory RewardedAdConfig.empty() => const RewardedAdConfig(
    enabled: true,
    adUnitId: 'ca-app-pub-3940256099942544/5224354917',
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
    adUnitId: 'ca-app-pub-3940256099942544/2247696110',
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
