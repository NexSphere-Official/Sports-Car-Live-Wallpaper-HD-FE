import 'package:dartz/dartz.dart';

import '../failures/consent_failure.dart';
import '../repositories/consent_manager.dart';

/// Whether a privacy-options entry point must be surfaced (UMP requires this in
/// regulated regions once consent info has been refreshed).
class IsPrivacyOptionsRequiredUseCase {
  final ConsentManager _consentManager;

  IsPrivacyOptionsRequiredUseCase(this._consentManager);

  Future<Either<ConsentFailure, bool>> execute() =>
      _consentManager.isPrivacyOptionsRequired();
}
