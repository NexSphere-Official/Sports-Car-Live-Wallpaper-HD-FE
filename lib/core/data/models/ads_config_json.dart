import '../../domain/models/ads_config.dart';

/// Parses the `ads` object nested in the Remote Config `app_config` value.
/// Remote values are overlaid on top of [AdsConfig.empty] in [toDomain] so any
/// missing key degrades to the built-in default rather than throwing — defaults
/// live in the domain model, not duplicated here.
///
/// Read-only inbound parser: Remote Config is authored server-side and never
/// written back, so this intentionally has no `toJson` (only `fromJson` +
/// `toDomain`).
class AdsConfigJson {
  final Map<String, dynamic> json;

  AdsConfigJson(this.json);

  factory AdsConfigJson.fromJson(Map<String, dynamic> json) =>
      AdsConfigJson(json);

  AdsConfig toDomain() {
    final defaults = AdsConfig.empty();
    return defaults.copyWith(
      enabled: _bool(json['enabled']),
      appOpen: _appOpen(_obj(json['app_open']), defaults.appOpen),
      interstitial: _interstitial(_obj(json['interstitial']), defaults.interstitial),
      rewarded: _rewarded(_obj(json['rewarded']), defaults.rewarded),
      native: _native(_obj(json['native']), defaults.native),
      unlockPattern: _pattern(json['unlock_pattern']),
    );
  }

  static AppOpenAdConfig _appOpen(
    Map<String, dynamic>? json,
    AppOpenAdConfig defaults,
  ) {
    if (json == null) return defaults;
    final resumeCooldown = _int(json['resume_cooldown_seconds']);
    final loadTimeout = _int(json['load_timeout_seconds']);
    return defaults.copyWith(
      enabled: _bool(json['enabled']),
      adUnitId: _str(json['ad_unit_id']),
      onColdStart: _bool(json['on_cold_start']),
      onResume: _bool(json['on_resume']),
      resumeCooldown:
          resumeCooldown == null ? null : Duration(seconds: resumeCooldown),
      loadTimeout: loadTimeout == null ? null : Duration(seconds: loadTimeout),
    );
  }

  static InterstitialAdConfig _interstitial(
    Map<String, dynamic>? json,
    InterstitialAdConfig defaults,
  ) {
    if (json == null) return defaults;
    final cooldown = _int(json['cooldown_seconds']);
    return defaults.copyWith(
      enabled: _bool(json['enabled']),
      adUnitId: _str(json['ad_unit_id']),
      onBackFromSaved: _bool(json['on_back_from_saved']),
      cooldown: cooldown == null ? null : Duration(seconds: cooldown),
    );
  }

  static RewardedAdConfig _rewarded(
    Map<String, dynamic>? json,
    RewardedAdConfig defaults,
  ) {
    if (json == null) return defaults;
    return defaults.copyWith(
      enabled: _bool(json['enabled']),
      adUnitId: _str(json['ad_unit_id']),
    );
  }

  static NativeAdConfig _native(
    Map<String, dynamic>? json,
    NativeAdConfig defaults,
  ) {
    if (json == null) return defaults;
    return defaults.copyWith(
      enabled: _bool(json['enabled']),
      adUnitId: _str(json['ad_unit_id']),
      gridInterval: _int(json['grid_interval']),
    );
  }

  /// Returns null when the value is missing/invalid so the caller keeps its
  /// default (used directly when non-empty).
  static List<AdSlotType>? _pattern(Object? raw) {
    if (raw is List) {
      final parsed = raw
          .whereType<String>()
          .map(AdSlotType.fromKey)
          .toList(growable: false);
      if (parsed.isNotEmpty) return parsed;
    }
    return null;
  }

  static Map<String, dynamic>? _obj(Object? value) =>
      value is Map<String, dynamic> ? value : null;

  // Each returns null when absent/wrong-typed so copyWith keeps the default.
  static String? _str(Object? value) =>
      value is String && value.isNotEmpty ? value : null;

  static bool? _bool(Object? value) => value is bool ? value : null;

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
