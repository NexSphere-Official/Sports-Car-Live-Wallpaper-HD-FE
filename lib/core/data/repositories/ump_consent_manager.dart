import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/failures/consent_failure.dart';
import '../../domain/repositories/consent_manager.dart';

/// UMP-backed [ConsentManager]. Follows Google's recommended order:
/// requestConsentInfoUpdate → loadAndShowConsentFormIfRequired → canRequestAds.
/// See https://developers.google.com/admob/flutter/privacy.
class UmpConsentManager implements ConsentManager {
  /// Upper bound on a consent-form wait so a stalled UMP/plugin callback can
  /// never hang the caller. On timeout we proceed with whatever consent state
  /// is currently cached.
  static const _formTimeout = Duration(seconds: 10);

  @override
  Future<Either<ConsentFailure, bool>> gatherConsent() async {
    try {
      final completer = Completer<void>();
      final params = ConsentRequestParameters();

      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          // Consent info refreshed — show the form if the region requires it.
          ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
            // Whether or not a form showed (or errored), we proceed; the
            // canRequestAds() read below reflects the resulting consent state.
            if (!completer.isCompleted) completer.complete();
          });
        },
        (FormError error) {
          // Failed to refresh consent info — proceed with cached/default state.
          if (!completer.isCompleted) completer.complete();
        },
      );

      // Continue regardless if the callbacks never fire within the window.
      await completer.future.timeout(_formTimeout, onTimeout: () {});
      return right(await ConsentInformation.instance.canRequestAds());
    } catch (ex) {
      return left(ConsentFailure.unknown(ex));
    }
  }

  @override
  Future<Either<ConsentFailure, bool>> canRequestAds() async {
    try {
      return right(await ConsentInformation.instance.canRequestAds());
    } catch (ex) {
      return left(ConsentFailure.unknown(ex));
    }
  }

  @override
  Future<Either<ConsentFailure, bool>> isPrivacyOptionsRequired() async {
    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      return right(status == PrivacyOptionsRequirementStatus.required);
    } catch (ex) {
      return left(ConsentFailure.unknown(ex));
    }
  }

  @override
  Future<Either<ConsentFailure, Unit>> showPrivacyOptionsForm() async {
    try {
      final completer = Completer<void>();
      ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (!completer.isCompleted) completer.complete();
      });
      // Don't wait forever if the form callback never fires.
      await completer.future.timeout(_formTimeout, onTimeout: () {});
      return right(unit);
    } catch (ex) {
      return left(ConsentFailure.unknown(ex));
    }
  }
}
