import 'package:dartz/dartz.dart';
import '../failures/settings_failure.dart';
import '../models/app_theme_mode.dart';

abstract class SettingsRepository {
  Future<Either<SettingsFailure, AppThemeMode>> getThemeMode();
  Future<Either<SettingsFailure, Unit>> saveThemeMode(AppThemeMode mode);
}
