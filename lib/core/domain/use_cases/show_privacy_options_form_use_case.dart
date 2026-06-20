import 'package:dartz/dartz.dart';

import '../failures/consent_failure.dart';
import '../repositories/consent_manager.dart';

/// Presents the UMP privacy-options form so the user can change their consent
/// choices.
class ShowPrivacyOptionsFormUseCase {
  final ConsentManager _consentManager;

  ShowPrivacyOptionsFormUseCase(this._consentManager);

  Future<Either<ConsentFailure, Unit>> execute() =>
      _consentManager.showPrivacyOptionsForm();
}
