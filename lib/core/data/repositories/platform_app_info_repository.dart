import 'package:dartz/dartz.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/failures/app_info_failure.dart';
import '../../domain/repositories/app_info_repository.dart';

class PlatformAppInfoRepository implements AppInfoRepository {
  /// Fallback id if package info can't be read (matches the applicationId).
  static const _fallbackPackageId =
      'com.nexsphere.hd.sports.car.live.wallpapers.topwallpapers';

  static const _privacyPolicyUrl =
      'https://nex-sphere.dev/privacy-policy/sports-car-wallpaper';

  @override
  Future<Either<AppInfoFailure, String>> appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return right('${info.version} (${info.buildNumber})');
    } catch (ex) {
      return left(AppInfoFailure.unknown(ex));
    }
  }

  @override
  Future<Either<AppInfoFailure, Unit>> shareApp() async {
    try {
      final url = await _storeWebUrl();
      await Share.share(
        'Check out Sports Car Live Wallpapers — 4K live & HD car '
        'wallpapers:\n$url',
        subject: 'Sports Car Live Wallpapers',
      );
      return right(unit);
    } catch (ex) {
      return left(AppInfoFailure.unknown(ex));
    }
  }

  @override
  Future<Either<AppInfoFailure, Unit>> openStoreListing() async {
    final id = await _packageId();
    final market = Uri.parse('market://details?id=$id');
    final web = Uri.parse('https://play.google.com/store/apps/details?id=$id');
    try {
      final opened = await launchUrl(
        market,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
      return right(unit);
    } catch (_) {
      // Play Store app unavailable — fall back to the web listing.
      try {
        await launchUrl(web, mode: LaunchMode.externalApplication);
        return right(unit);
      } catch (ex) {
        return left(AppInfoFailure.unknown(ex));
      }
    }
  }

  @override
  Future<Either<AppInfoFailure, String>> privacyPolicyUrl() async =>
      right(_privacyPolicyUrl);

  Future<String> _packageId() async {
    try {
      return (await PackageInfo.fromPlatform()).packageName;
    } catch (_) {
      return _fallbackPackageId;
    }
  }

  Future<String> _storeWebUrl() async =>
      'https://play.google.com/store/apps/details?id=${await _packageId()}';
}
