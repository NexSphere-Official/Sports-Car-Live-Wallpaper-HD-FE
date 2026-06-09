import '../../models/app_config.dart';

class AppConfigState {
  final AppConfig config;
  const AppConfigState({required this.config});

  AppConfigState copyWith({AppConfig? config}) =>
      AppConfigState(config: config ?? this.config);
}
