import 'package:dartz/dartz.dart';

import '../failures/consent_failure.dart';

/// Wraps Google's User Messaging Platform (UMP) consent flow. Implementations
/// gather GDPR/privacy consent before any ads are requested and expose the
/// privacy options entry point required in regulated regions.
abstract class ConsentManager {
  /// Run the consent flow at app launch: refresh consent info and show the
  /// consent form if one is required. Resolves with whether ads can be
  /// requested afterwards.
  Future<Either<ConsentFailure, bool>> gatherConsent();

  /// Whether a privacy options entry point must be surfaced (e.g. in Settings).
  Future<Either<ConsentFailure, bool>> isPrivacyOptionsRequired();

  /// Present the privacy options form so the user can change their choices.
  Future<Either<ConsentFailure, Unit>> showPrivacyOptionsForm();
}
