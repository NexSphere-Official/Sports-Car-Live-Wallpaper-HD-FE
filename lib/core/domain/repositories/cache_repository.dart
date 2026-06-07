import 'package:dartz/dartz.dart';
import '../failures/settings_failure.dart';

abstract class CacheRepository {
  Future<Either<SettingsFailure, Unit>> clear();
}
