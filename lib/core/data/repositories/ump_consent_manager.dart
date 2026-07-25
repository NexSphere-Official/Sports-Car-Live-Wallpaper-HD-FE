import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/failures/consent_failure.dart';
import '../../domain/repositories/consent_manager.dart';

/// UMP-backed [ConsentManager]. Follows Google's recommended order:
/// requestConsentInfoUpdate → loadAndShowConsentFormIfRequired → canRequestAds.
/// See https://developers.google.com/admob/flutter/privacy.
class UmpConsentManager implements ConsentManager {
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

      // NO TIMEOUT HERE, deliberately. This future resolves only once the user
      // has actually finished with the consent form, however long they take.
      // Cutting it short used to read canRequestAds() while the form was still
      // on screen, latch "false" for the whole session, and silently serve a
      // consenting user no ads at all. Callers that must not block (launch)
      // apply their own deadline and re-check when this resolves.
      await completer.future;
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
      // Also untimed: the caller re-reads consent as soon as this resolves, so
      // returning while the form is still up would refresh against the state
      // the user is in the middle of changing. The form is on screen by the
      // user's own action, so the callback arrives when they dismiss it.
      await completer.future;
      return right(unit);
    } catch (ex) {
      return left(ConsentFailure.unknown(ex));
    }
  }
}
