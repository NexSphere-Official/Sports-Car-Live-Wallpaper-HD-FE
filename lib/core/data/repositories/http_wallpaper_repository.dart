import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../models/wallpaper_json.dart';
import '../../domain/failures/get_wallpapers_failure.dart';
import '../../domain/models/wallpaper.dart';
import '../../domain/models/wallpaper_filter.dart';
import '../../domain/repositories/wallpaper_repository.dart';

class HttpWallpaperRepository implements WallpaperRepository {
  HttpWallpaperRepository(this._client);

  final http.Client _client;

  static const _host = 'api.badalabs.com';
  static const _packageName = 'com.badalabs.carwallpapers';

  @override
  Future<Either<GetWallpapersFailure, List<Wallpaper>>> getWallpapers({
    required WallpaperFilter filter,
    required int limit,
    required int offset,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
        'packageName': _packageName,
        'sort': _sortParam(filter.sort),
        'type': _typeParam(filter.type),
      };

      final uri = Uri.https(_host, '/wallpapers', params);
      final response = await _client
          .get(uri, headers: {'accept': '*/*'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return left(
          GetWallpapersFailure.network('status ${response.statusCode}'),
        );
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      final wallpapers = decoded
          .whereType<Map<String, dynamic>>()
          .map((json) => WallpaperJson.fromJson(json).toDomain())
          .toList();
      return right(wallpapers);
    } on http.ClientException catch (ex) {
      return left(GetWallpapersFailure.network(ex));
    } on TimeoutException catch (ex) {
      return left(GetWallpapersFailure.network(ex));
    } on SocketException catch (ex) {
      return left(GetWallpapersFailure.network(ex));
    } catch (ex) {
      return left(GetWallpapersFailure.unknown(ex));
    }
  }

  String _sortParam(WallpaperSort sort) {
    switch (sort) {
      case WallpaperSort.popular:
        return 'popular';
      case WallpaperSort.random:
        return 'random';
      case WallpaperSort.latest:
        return 'latest';
    }
  }

  String _typeParam(WallpaperType type) {
    switch (type) {
      case WallpaperType.still:
        return 'static';
      case WallpaperType.live:
        return 'live';
      case WallpaperType.all:
        return 'all';
    }
  }
}
