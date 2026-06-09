import 'package:dartz/dartz.dart';
import '../failures/app_info_failure.dart';

/// Platform-facing app actions: version lookup and outbound links/shares.
abstract class AppInfoRepository {
  /// Human-readable version string, e.g. `1.0.0 (1)`.
  Future<Either<AppInfoFailure, String>> appVersion();

  /// Opens the system share sheet with the store link.
  Future<Either<AppInfoFailure, Unit>> shareApp();

  /// Opens the app's store listing (for rating).
  Future<Either<AppInfoFailure, Unit>> openStoreListing();

  /// The privacy policy URL — rendered inside the app, not launched externally.
  Future<Either<AppInfoFailure, String>> privacyPolicyUrl();
}
