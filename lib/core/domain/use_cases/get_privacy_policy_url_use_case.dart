import 'package:dartz/dartz.dart';
import '../failures/app_info_failure.dart';
import '../repositories/app_info_repository.dart';

class GetPrivacyPolicyUrlUseCase {
  final AppInfoRepository _appInfoRepository;
  GetPrivacyPolicyUrlUseCase(this._appInfoRepository);

  Future<Either<AppInfoFailure, String>> execute() =>
      _appInfoRepository.privacyPolicyUrl();
}
