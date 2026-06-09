import 'package:dartz/dartz.dart';
import '../failures/app_config_failure.dart';
import '../models/app_config.dart';

abstract class AppConfigRepository {
  Future<Either<AppConfigFailure, AppConfig>> fetchAppConfig();
}
