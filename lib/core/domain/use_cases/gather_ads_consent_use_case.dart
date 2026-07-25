import 'dart:async';

import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../repositories/app_open_ad_manager.dart';
import '../repositories/consent_manager.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';

/// Bootstraps ads during app launch: gathers UMP consent, then — when ads are
/// enabled in Remote Config and consent permits — initializes the ads SDK and
/// starts app-open ad management (preload + foreground shows). Records the
/// resulting readiness in [AdsStore] so features can gate ad rendering on it.
/// Reads [AppConfigStore], so it must run after the app config is fetched.
class GatherAdsConsentUseCase {
  final ConsentManager _consentManager;
  final AdsService _adsService;
  final AppOpenAdManager _appOpenAdManager;
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;

  GatherAdsConsentUseCase(
    this._consentManager,
    this._adsService,
    this._appOpenAdManager,
    this._appConfigStore,
    this._adsStore,
  );

  /// How long launch will wait on the consent flow before handing off to the
  /// app. Reading a first-run consent form takes longer than any launch budget
  /// we'd accept, so this is a hand-off point, not a verdict — see [execute].
  static const _launchDeadline = Duration(seconds: 8);

  /// Returns whether ads are ready *by the time launch needs an answer*. A
  /// `false` here is not final: if the user is still working through the
  /// consent form, readiness is applied to [AdsStore] the moment they finish,
  /// and the UI picks it up from the store's stream.
  Future<Either<AdsFailure, bool>> execute() async {
    // Refresh UMP consent on every launch (Google guidance), even when ads are
    // disabled — this keeps the privacy-options requirement status and consent
    // state current for the Settings entry point. A consent failure is treated
    // as "cannot request ads" rather than blocking launch.
    final consent = _consentManager.gatherConsent();

    bool? canRequestAds;
    await consent
        .then<void>((result) => canRequestAds = result.getOrElse(() => false))
        .timeout(_launchDeadline, onTimeout: () {});

    final resolved = canRequestAds;
    if (resolved == null) {
      // Still on the consent form. Don't hold launch — but don't write the
      // session off either: apply readiness the moment the user is done.
      unawaited(
        consent.then(
          (result) => _applyReadiness(
            result.getOrElse(() => false),
            // The splash is long gone by now — no cold start to wait on.
            atLaunch: false,
          ),
        ),
      );
      _adsStore.setCanRequestAds(false);
      return right(false);
    }

    return _applyReadiness(resolved, atLaunch: true);
  }

  /// Gates on Remote Config + consent, initializes the SDK, and records the
  /// outcome in [AdsStore]. Safe to run twice (SDK init is idempotent).
  Future<Either<AdsFailure, bool>> _applyReadiness(
    bool canRequestAds, {
    required bool atLaunch,
  }) async {
    final ads = _appConfigStore.config.ads;
    if (!ads.enabled || !canRequestAds) {
      _adsStore.setCanRequestAds(false);
      return right(false);
    }

    final init = await _adsService.initialize();
    return init.fold(
      (failure) async {
        _adsStore.setCanRequestAds(false);
        return left<AdsFailure, bool>(failure);
      },
      (_) async {
        _adsStore.setCanRequestAds(true);
        // Begin preloading app-open ads (and resume-show wiring) now that the
        // SDK is ready, so a cold-start ad can be ready by the splash's end.
        if (ads.appOpen.isUsable) {
          await _appOpenAdManager.start(
            ads.appOpen,
            expectColdStart: atLaunch,
          );
        }
        return right<AdsFailure, bool>(true);
      },
    );
  }
}
