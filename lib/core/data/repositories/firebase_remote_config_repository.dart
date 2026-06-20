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

  @override
  Future<Either<AppConfigFailure, AppConfig>> fetchAppConfig() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 15),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (ex) {
      // Network/fetch failure: fall back to whatever is cached, or the built-in
      // defaults in AppConfig.empty(), rather than blocking app startup.
      return _readConfig(fetchError: ex);
    }
    return _readConfig();
  }

  Either<AppConfigFailure, AppConfig> _readConfig({Object? fetchError}) {
    // Never reached Remote Config (and nothing cached): use the defaults baked
    // into AppConfig.empty(). The API base URL stays empty by design.
    final raw = _remoteConfig.getString(_appConfigKey);
    if (raw.isEmpty) return right(AppConfig.empty());

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return right(AppConfigJson.fromJson(decoded).toDomain());
    } catch (ex) {
      // Value present but unparseable — surface a typed failure.
      return left(
        fetchError != null
            ? AppConfigFailure.fetch(fetchError)
            : AppConfigFailure.parse(ex),
      );
    }
  }
}
