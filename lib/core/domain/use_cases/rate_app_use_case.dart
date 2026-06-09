import 'package:dartz/dartz.dart';
import '../failures/app_info_failure.dart';
import '../repositories/app_info_repository.dart';

class RateAppUseCase {
  final AppInfoRepository _appInfoRepository;
  RateAppUseCase(this._appInfoRepository);

  Future<Either<AppInfoFailure, Unit>> execute() =>
      _appInfoRepository.openStoreListing();
}
