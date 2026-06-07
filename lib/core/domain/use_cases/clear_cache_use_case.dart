import 'package:dartz/dartz.dart';
import '../failures/settings_failure.dart';
import '../repositories/cache_repository.dart';

class ClearCacheUseCase {
  final CacheRepository _cacheRepository;
  ClearCacheUseCase(this._cacheRepository);

  Future<Either<SettingsFailure, Unit>> execute() => _cacheRepository.clear();
}
