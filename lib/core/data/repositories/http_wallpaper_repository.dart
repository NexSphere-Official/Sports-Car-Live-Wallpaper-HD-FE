import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../models/wallpaper_json.dart';
import '../models/wallpaper_page_json.dart';
import '../../domain/failures/get_wallpapers_failure.dart';
import '../../domain/models/wallpaper.dart';
import '../../domain/models/wallpaper_page.dart';
import '../../domain/models/wallpaper_type.dart';
import '../../domain/repositories/wallpaper_repository.dart';

class HttpWallpaperRepository implements WallpaperRepository {
  HttpWallpaperRepository(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 20);

  @override
  Future<Either<GetWallpapersFailure, WallpaperPage>> getWallpapers({
    required String baseUrl,
    required WallpaperType type,
    int? limit,
    String? cursor,
  }) async {
    final params = <String, String>{
      if (limit != null) 'limit': '$limit',
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    return _request(
      baseUrl: baseUrl,
      path: _feedPath(type),
      query: params,
      onData: (data) => WallpaperPageJson.fromJson(data).toDomain(),
    );
  }

  @override
  Future<Either<GetWallpapersFailure, Wallpaper>> getWallpaperById({
    required String baseUrl,
    required String id,
  }) async {
    return _request(
      baseUrl: baseUrl,
      path: '/v1/wallpapers/$id',
      query: const {},
      onData: (data) {
        final raw = data['wallpaper'] as Map<String, dynamic>? ?? const {};
        return WallpaperJson.fromJson(raw).toDomain();
      },
    );
  }

  /// Performs a GET, unwraps the `{ success, data, error }` envelope, and maps
  /// failures into [GetWallpapersFailure]. Never throws.
  Future<Either<GetWallpapersFailure, T>> _request<T>({
    required String baseUrl,
    required String path,
    required Map<String, String> query,
    required T Function(Map<String, dynamic> data) onData,
  }) async {
    if (baseUrl.isEmpty) {
      return left(const GetWallpapersFailure.network('missing base url'));
    }

    try {
      final uri = Uri.parse('$baseUrl$path').replace(
        queryParameters: query.isEmpty ? null : query,
      );
      final response = await _client
          .get(uri, headers: {'accept': 'application/json'})
          .timeout(_timeout);

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return left(
          GetWallpapersFailure.network('status ${response.statusCode}'),
        );
      }

      if (decoded['success'] == true) {
        final data = decoded['data'] as Map<String, dynamic>? ?? const {};
        return right(onData(data));
      }

      final error = decoded['error'] as Map<String, dynamic>? ?? const {};
      return left(_mapError(error['code'] as String?, response.statusCode));
    } on http.ClientException catch (ex) {
      return left(GetWallpapersFailure.network(ex));
    } on TimeoutException catch (ex) {
      return left(GetWallpapersFailure.network(ex));
    } on SocketException catch (ex) {
      return left(GetWallpapersFailure.network(ex));
    } on FormatException catch (ex) {
      return left(GetWallpapersFailure.unknown(ex));
    } catch (ex) {
      return left(GetWallpapersFailure.unknown(ex));
    }
  }

  GetWallpapersFailure _mapError(String? code, int statusCode) {
    switch (code) {
      case 'NOT_FOUND':
        return GetWallpapersFailure.notFound(code);
      case 'RATE_LIMITED':
      case 'INVALID_CURSOR':
        return GetWallpapersFailure.network(code ?? 'status $statusCode');
      default:
        return GetWallpapersFailure.unknown(code ?? 'status $statusCode');
    }
  }

  String _feedPath(WallpaperType type) {
    switch (type) {
      case WallpaperType.all:
        return '/v1/wallpapers';
      case WallpaperType.live:
        return '/v1/wallpapers/live';
      case WallpaperType.still:
        return '/v1/wallpapers/static';
    }
  }
}
