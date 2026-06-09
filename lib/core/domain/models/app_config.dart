import 'package:equatable/equatable.dart';

/// Remote, runtime-configurable app settings sourced from Firebase Remote
/// Config (the `app_config` parameter). Nothing here is hardcoded in the app
/// beyond a fallback default supplied to Remote Config.
class AppConfig extends Equatable {
  final String apiBaseUrl;

  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.empty() => const AppConfig(apiBaseUrl: '');

  bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;

  AppConfig copyWith({String? apiBaseUrl}) =>
      AppConfig(apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl);

  @override
  List<Object?> get props => [apiBaseUrl];
}
