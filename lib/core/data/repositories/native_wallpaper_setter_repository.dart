import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../domain/failures/set_wallpaper_failure.dart';
import '../../domain/models/wallpaper_surface.dart';
import '../../domain/repositories/wallpaper_setter_repository.dart';

class NativeWallpaperSetterRepository implements WallpaperSetterRepository {
  NativeWallpaperSetterRepository(this._client);

  static const MethodChannel _channel = MethodChannel(
    'com.nexsphere.hd.sports.car.live.wallpapers.topwallpapers/wallpaper',
  );

  final http.Client _client;

  @override
  Future<Either<SetWallpaperFailure, Unit>> setStatic(
    String imageUrl,
    WallpaperSurface surface,
  ) async {
    final String filePath;
    try {
      filePath = await _downloadFile(
        imageUrl,
        prefix: 'static_wallpaper',
        extension: '.jpg',
      );
    } catch (ex) {
      return left(SetWallpaperFailure.download(ex));
    }

    try {
      final result = await _channel.invokeMethod<bool>('setStaticWallpaper', {
        'filePath': filePath,
        'target': surface.name,
      });
      return result == true
          ? right(unit)
          : left(const SetWallpaperFailure.unknown());
    } catch (ex) {
      return left(SetWallpaperFailure.unknown(ex));
    } finally {
      await _deleteIfExists(filePath);
    }
  }

  @override
  Future<Either<SetWallpaperFailure, Unit>> setLive(String videoUrl) async {
    final String filePath;
    try {
      filePath = await _downloadFile(
        videoUrl,
        prefix: 'live_wallpaper',
        extension: '.mp4',
      );
    } catch (ex) {
      return left(SetWallpaperFailure.download(ex));
    }

    try {
      final result = await _channel.invokeMethod<bool>('setLiveWallpaper', {
        'filePath': filePath,
      });
      return result == true
          ? right(unit)
          : left(const SetWallpaperFailure.unknown());
    } catch (ex) {
      return left(SetWallpaperFailure.unknown(ex));
    } finally {
      await _deleteIfExists(filePath);
    }
  }

  @override
  Future<Either<SetWallpaperFailure, bool>> isLiveWallpaperActive() async {
    try {
      final result = await _channel.invokeMethod<bool>('isLiveWallpaperSet');
      return right(result == true);
    } catch (ex) {
      return left(SetWallpaperFailure.unknown(ex));
    }
  }

  Future<String> _downloadFile(
    String url, {
    required String prefix,
    required String extension,
  }) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('status ${response.statusCode}');
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }

  Future<void> _deleteIfExists(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
