import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/failures/settings_failure.dart';
import '../../domain/repositories/cache_repository.dart';

class FlutterCacheRepository implements CacheRepository {
  @override
  Future<Either<SettingsFailure, Unit>> clear() async {
    try {
      await DefaultCacheManager().emptyCache();
      await _clearTempVideos();
      return right(unit);
    } catch (ex) {
      return left(SettingsFailure.unknown(ex));
    }
  }

  Future<void> _clearTempVideos() async {
    final dir = await getTemporaryDirectory();
    if (!dir.existsSync()) return;
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.contains('live_wallpaper_')) {
        try {
          await entity.delete();
        } catch (_) {
          // Ignore individual file deletion failures.
        }
      }
    }
  }
}
