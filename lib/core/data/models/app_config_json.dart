import '../../domain/models/app_config.dart';

/// Serialization for the Remote Config `app_config` JSON value:
/// `{ "api_base_url": "https://..." }`.
class AppConfigJson {
  final String apiBaseUrl;

  AppConfigJson({required this.apiBaseUrl});

  factory AppConfigJson.fromJson(Map<String, dynamic> json) => AppConfigJson(
    apiBaseUrl: json['api_base_url'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'api_base_url': apiBaseUrl};

  AppConfig toDomain() => AppConfig(apiBaseUrl: apiBaseUrl);
}
