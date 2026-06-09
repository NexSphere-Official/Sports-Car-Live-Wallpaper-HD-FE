import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/app_config.dart';
import 'app_config_state.dart';

/// Long-lived holder for the remotely-fetched [AppConfig]. Populated once at
/// startup by GetAppConfigUseCase and read by the data layer at request time
/// so no base URL is hardcoded in the app's business logic.
class AppConfigStore extends Cubit<AppConfigState> {
  AppConfigStore() : super(AppConfigState(config: AppConfig.empty()));

  AppConfig get config => state.config;
  String get apiBaseUrl => state.config.apiBaseUrl;

  void setConfig(AppConfig config) => emit(state.copyWith(config: config));
}
