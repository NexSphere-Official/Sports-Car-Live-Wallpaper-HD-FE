import '../../domain/models/wallpaper_page.dart';
import 'wallpaper_json.dart';

/// Parses the `data` payload of a list response:
/// `{ "wallpapers": [...], "pagination": { next_cursor, has_more, limit } }`.
class WallpaperPageJson {
  final List<WallpaperJson> wallpapers;
  final String? nextCursor;
  final bool hasMore;

  WallpaperPageJson({
    required this.wallpapers,
    required this.nextCursor,
    required this.hasMore,
  });

  factory WallpaperPageJson.fromJson(Map<String, dynamic> json) {
    final rawList = (json['wallpapers'] as List?) ?? const [];
    final pagination =
        json['pagination'] as Map<String, dynamic>? ?? const {};
    return WallpaperPageJson(
      wallpapers: rawList
          .whereType<Map<String, dynamic>>()
          .map(WallpaperJson.fromJson)
          .toList(),
      nextCursor: pagination['next_cursor'] as String?,
      hasMore: pagination['has_more'] as bool? ?? false,
    );
  }

  WallpaperPage toDomain() => WallpaperPage(
    wallpapers: wallpapers.map((w) => w.toDomain()).toList(),
    nextCursor: nextCursor,
    hasMore: hasMore,
  );
}
