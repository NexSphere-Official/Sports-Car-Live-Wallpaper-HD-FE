import '../../domain/models/app_config.dart';
import 'ads_config_json.dart';

/// Parses the Remote Config `app_config` JSON value:
/// `{ "api_base_url": "https://...", "ads": { ... } }`.
///
/// Read-only inbound parser: Remote Config is authored server-side and the app
/// never writes it back, so this intentionally has no `toJson` (only `fromJson`
/// + `toDomain`).
class AppConfigJson {
  final String apiBaseUrl;
  final Map<String, dynamic>? ads;

  AppConfigJson({required this.apiBaseUrl, this.ads});

  factory AppConfigJson.fromJson(Map<String, dynamic> json) => AppConfigJson(
    apiBaseUrl: json['api_base_url'] as String? ?? '',
    ads: json['ads'] is Map<String, dynamic>
        ? json['ads'] as Map<String, dynamic>
        : null,
  );

  AppConfig toDomain() => AppConfig(
    apiBaseUrl: apiBaseUrl,
    ads: AdsConfigJson.fromJson(ads ?? const {}).toDomain(),
  );
}
