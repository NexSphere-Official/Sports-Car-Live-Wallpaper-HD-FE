import 'package:dartz/dartz.dart';
import '../failures/app_config_failure.dart';
import '../models/app_config.dart';
import '../repositories/app_config_repository.dart';
import '../stores/app_config/app_config_store.dart';

class GetAppConfigUseCase {
  final AppConfigRepository _appConfigRepository;
  final AppConfigStore _appConfigStore;
  GetAppConfigUseCase(this._appConfigRepository, this._appConfigStore);

  Future<Either<AppConfigFailure, AppConfig>> execute() =>
      _appConfigRepository.fetchAppConfig().then(
        (result) => result.fold(left, (config) {
          _appConfigStore.setConfig(config);
          return right(config);
        }),
      );
}
