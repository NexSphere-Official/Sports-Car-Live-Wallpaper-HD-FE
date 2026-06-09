import 'package:dartz/dartz.dart';
import '../failures/app_info_failure.dart';
import '../repositories/app_info_repository.dart';

class GetAppVersionUseCase {
  final AppInfoRepository _appInfoRepository;
  GetAppVersionUseCase(this._appInfoRepository);

  Future<Either<AppInfoFailure, String>> execute() =>
      _appInfoRepository.appVersion();
}
