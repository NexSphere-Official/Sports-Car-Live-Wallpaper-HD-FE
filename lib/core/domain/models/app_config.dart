import 'package:equatable/equatable.dart';

import 'ads_config.dart';

/// Remote, runtime-configurable app settings sourced from Firebase Remote
/// Config (the `app_config` parameter). Nothing here is hardcoded in the app
/// beyond a fallback default supplied to Remote Config.
class AppConfig extends Equatable {
  final String apiBaseUrl;
  final AdsConfig ads;

  const AppConfig({required this.apiBaseUrl, required this.ads});

  /// Safe defaults used before/without Remote Config. The API base URL has no
  /// default — it must come from Remote Config — but ad settings default to
  /// [AdsConfig.empty].
  factory AppConfig.empty() =>
      AppConfig(apiBaseUrl: '', ads: AdsConfig.empty());

  bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;

  AppConfig copyWith({String? apiBaseUrl, AdsConfig? ads}) =>
      AppConfig(apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl, ads: ads ?? this.ads);

  @override
  List<Object?> get props => [apiBaseUrl, ads];
}
