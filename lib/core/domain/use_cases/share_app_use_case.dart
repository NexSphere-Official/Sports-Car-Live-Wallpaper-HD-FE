import 'package:dartz/dartz.dart';
import '../failures/app_info_failure.dart';
import '../repositories/app_info_repository.dart';

class ShareAppUseCase {
  final AppInfoRepository _appInfoRepository;
  ShareAppUseCase(this._appInfoRepository);

  Future<Either<AppInfoFailure, Unit>> execute() =>
      _appInfoRepository.shareApp();
}
