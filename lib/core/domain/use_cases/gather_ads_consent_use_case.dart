import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../repositories/app_open_ad_manager.dart';
import '../repositories/consent_manager.dart';
import '../stores/app_config/app_config_store.dart';

/// Bootstraps ads during app launch: gathers UMP consent, then — when ads are
/// enabled in Remote Config and consent permits — initializes the ads SDK and
/// starts app-open ad management (preload + foreground shows). Reads
/// [AppConfigStore], so it must run after the app config is fetched. Returns
/// true when the SDK was initialized and ads may be requested.
class GatherAdsConsentUseCase {
  final ConsentManager _consentManager;
  final AdsService _adsService;
  final AppOpenAdManager _appOpenAdManager;
  final AppConfigStore _appConfigStore;

  GatherAdsConsentUseCase(
    this._consentManager,
    this._adsService,
    this._appOpenAdManager,
    this._appConfigStore,
  );

  Future<Either<AdsFailure, bool>> execute() async {
    // Refresh UMP consent on every launch (Google guidance), even when ads are
    // disabled — this keeps the privacy-options requirement status and consent
    // state current for the Settings entry point. A consent failure is treated
    // as "cannot request ads" rather than blocking launch.
    final consent = await _consentManager.gatherConsent();
    final canRequestAds = consent.getOrElse(() => false);

    // Only initialize/request ads when Remote Config enables them and consent
    // permits ad requests.
    final ads = _appConfigStore.config.ads;
    if (!ads.enabled || !canRequestAds) return right(false);

    final init = await _adsService.initialize();
    return init.fold(
      (failure) async => left<AdsFailure, bool>(failure),
      (_) async {
        // Begin preloading app-open ads (and resume-show wiring) now that the
        // SDK is ready, so a cold-start ad can be ready by the splash's end.
        if (ads.appOpen.isUsable) await _appOpenAdManager.start(ads.appOpen);
        return right<AdsFailure, bool>(true);
      },
    );
  }
}
