import '../../domain/models/wallpaper.dart';
import '../../domain/models/wallpaper_kind.dart';

/// Serialization for the API wallpaper object:
/// `{ id, type, url, thumbnail, created_at }`.
///
/// Also used to persist favorites locally via [toJson] / [fromJson].
class WallpaperJson {
  final String id;
  final String type;
  final String url;
  final String thumbnail;
  final String createdAt;

  WallpaperJson({
    required this.id,
    required this.type,
    required this.url,
    required this.thumbnail,
    required this.createdAt,
  });

  factory WallpaperJson.fromJson(Map<String, dynamic> json) => WallpaperJson(
    id: json['id'] as String? ?? '',
    type: json['type'] as String? ?? '',
    url: json['url'] as String? ?? '',
    thumbnail: json['thumbnail'] as String? ?? '',
    createdAt: json['created_at'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'url': url,
    'thumbnail': thumbnail,
    'created_at': createdAt,
  };

  factory WallpaperJson.fromDomain(Wallpaper w) => WallpaperJson(
    id: w.id,
    type: _kindToString(w.kind),
    url: w.url,
    thumbnail: w.thumbnail,
    createdAt: w.createdAt.toIso8601String(),
  );

  Wallpaper toDomain() => Wallpaper(
    id: id,
    kind: _parseKind(type),
    url: url,
    thumbnail: thumbnail,
    createdAt: DateTime.tryParse(createdAt) ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  static WallpaperKind _parseKind(String value) {
    switch (value) {
      case 'live':
        return WallpaperKind.live;
      case 'static':
      default:
        return WallpaperKind.still;
    }
  }

  static String _kindToString(WallpaperKind kind) {
    switch (kind) {
      case WallpaperKind.live:
        return 'live';
      case WallpaperKind.still:
        return 'static';
    }
  }
}
