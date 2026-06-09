import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/app_config_json.dart';
import '../../domain/failures/app_config_failure.dart';
import '../../domain/models/app_config.dart';
import '../../domain/repositories/app_config_repository.dart';

class FirebaseRemoteConfigRepository implements AppConfigRepository {
  FirebaseRemoteConfigRepository(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  /// Remote Config parameter key (published in the Firebase console).
  static const _appConfigKey = 'app_config';

  /// Fallback used only when the device has never reached Remote Config.
  /// The live value is published server-side and overrides this.
  static const _fallbackAppConfig =
      '{"api_base_url":"https://sports-car-wallpaper-api.nex-sphere.dev"}';

  @override
  Future<Either<AppConfigFailure, AppConfig>> fetchAppConfig() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 15),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.setDefaults(const {
        _appConfigKey: _fallbackAppConfig,
      });
      await _remoteConfig.fetchAndActivate();
    } catch (ex) {
      // Network/fetch failure: fall back to whatever is cached or the default
      // below rather than blocking app startup.
      return _readConfig(fetchError: ex);
    }
    return _readConfig();
  }

  Either<AppConfigFailure, AppConfig> _readConfig({Object? fetchError}) {
    try {
      final raw = _remoteConfig.getString(_appConfigKey);
      final source = raw.isNotEmpty ? raw : _fallbackAppConfig;
      final decoded = jsonDecode(source) as Map<String, dynamic>;
      return right(AppConfigJson.fromJson(decoded).toDomain());
    } catch (ex) {
      // Could not even parse the fallback — surface a typed failure.
      return left(
        fetchError != null
            ? AppConfigFailure.fetch(fetchError)
            : AppConfigFailure.parse(ex),
      );
    }
  }
}
