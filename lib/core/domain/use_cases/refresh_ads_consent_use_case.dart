import 'package:dartz/dartz.dart';

import '../failures/ads_failure.dart';
import '../repositories/ads_service.dart';
import '../repositories/app_open_ad_manager.dart';
import '../repositories/consent_manager.dart';
import '../repositories/native_ad_cache.dart';
import '../stores/ads/ads_store.dart';
import '../stores/app_config/app_config_store.dart';

/// Re-evaluates ad readiness after the user changes consent via the privacy
/// options form, and updates [AdsStore] so live ad placements (e.g. the home
/// native slots) react immediately. Also starts/stops app-open management so a
/// revoke halts app-open ads at once (and a re-grant resumes them) without a
/// relaunch. Mirrors the gating in GatherAdsConsentUseCase.
class RefreshAdsConsentUseCase {
  final ConsentManager _consentManager;
  final AdsService _adsService;
  final AppOpenAdManager _appOpenAdManager;
  final AppConfigStore _appConfigStore;
  final AdsStore _adsStore;
  final NativeAdCache _nativeAdCache;

  RefreshAdsConsentUseCase(
    this._consentManager,
    this._adsService,
    this._appOpenAdManager,
    this._appConfigStore,
    this._adsStore,
    this._nativeAdCache,
  );

  Future<Either<AdsFailure, bool>> execute() async {
    final canRequestAds =
        (await _consentManager.canRequestAds()).getOrElse(() => false);

    final ads = _appConfigStore.config.ads;
    if (!ads.enabled || !canRequestAds) {
      _adsStore.setCanRequestAds(false);
      // Consent gone (or ads disabled) → stop every format and drop anything
      // already loaded. Previously only app-open was torn down, so a native ad
      // already on screen and any full-screen load still in flight outlived
      // the consent that permitted them.
      await _appOpenAdManager.stop();
      await _adsService.stop();
      _nativeAdCache.clear();
      return right(false);
    }

    // Idempotent — already initialized at startup in the common case.
    final init = await _adsService.initialize();
    return init.fold(
      (failure) async {
        _adsStore.setCanRequestAds(false);
        await _appOpenAdManager.stop();
        await _adsService.stop();
        _nativeAdCache.clear();
        return left<AdsFailure, bool>(failure);
      },
      (_) async {
        _adsStore.setCanRequestAds(true);
        // Resume (or begin) app-open management now that ads can be requested.
        if (ads.appOpen.isUsable) {
          // Mid-session: resume ads must work from the next foreground on.
          await _appOpenAdManager.start(
            ads.appOpen,
            expectColdStart: false,
          );
        } else {
          await _appOpenAdManager.stop();
        }
        return right<AdsFailure, bool>(true);
      },
    );
  }
}
