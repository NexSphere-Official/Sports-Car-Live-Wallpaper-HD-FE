import '../../domain/models/wallpaper.dart';
import '../../domain/models/wallpaper_category.dart';
import '../../domain/models/wallpaper_stats.dart';

class WallpaperJson {
  final int id;
  final String imageUrl;
  final String thumbnailImageUrl;
  final String videoUrl;
  final int imageWidth;
  final int imageHeight;
  final String createdAt;
  final String title;
  final String content;
  final int viewCount;
  final int downloadCount;
  final int bookmarkCount;
  final List<String> tags;
  final List<WallpaperCategory> categories;

  WallpaperJson({
    required this.id,
    required this.imageUrl,
    required this.thumbnailImageUrl,
    required this.videoUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.createdAt,
    required this.title,
    required this.content,
    required this.viewCount,
    required this.downloadCount,
    required this.bookmarkCount,
    required this.tags,
    required this.categories,
  });

  factory WallpaperJson.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? const {};
    final metadata = json['metadata'] as Map<String, dynamic>? ?? const {};
    final rawTags = (metadata['tags'] as List?) ?? const [];
    final rawCategories = (metadata['categories'] as List?) ?? const [];

    return WallpaperJson(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      thumbnailImageUrl: json['thumbnailImageUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      imageWidth: (json['imageWidth'] as num?)?.toInt() ?? 0,
      imageHeight: (json['imageHeight'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      title: metadata['title'] as String? ?? '',
      content: metadata['content'] as String? ?? '',
      viewCount: (stats['viewCount'] as num?)?.toInt() ?? 0,
      downloadCount: (stats['downloadCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (stats['bookmarkCount'] as num?)?.toInt() ?? 0,
      tags: rawTags
          .whereType<Map<String, dynamic>>()
          .map((t) => t['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      categories: rawCategories
          .whereType<Map<String, dynamic>>()
          .map(
            (c) => WallpaperCategory(
              id: (c['id'] as num?)?.toInt() ?? 0,
              name: c['name'] as String? ?? '',
              slug: c['slug'] as String? ?? '',
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'thumbnailImageUrl': thumbnailImageUrl,
    'videoUrl': videoUrl,
    'imageWidth': imageWidth,
    'imageHeight': imageHeight,
    'createdAt': createdAt,
    'stats': {
      'viewCount': viewCount,
      'downloadCount': downloadCount,
      'bookmarkCount': bookmarkCount,
    },
    'metadata': {
      'title': title,
      'content': content,
      'tags': tags.map((name) => {'name': name}).toList(),
      'categories': categories
          .map((c) => {'id': c.id, 'name': c.name, 'slug': c.slug})
          .toList(),
    },
  };

  factory WallpaperJson.fromDomain(Wallpaper w) => WallpaperJson(
    id: int.tryParse(w.id) ?? 0,
    imageUrl: w.imageUrl,
    thumbnailImageUrl: w.thumbnailUrl,
    videoUrl: w.videoUrl,
    imageWidth: w.width,
    imageHeight: w.height,
    createdAt: w.createdAt.toIso8601String(),
    title: w.title,
    content: w.description,
    viewCount: w.stats.views,
    downloadCount: w.stats.downloads,
    bookmarkCount: w.stats.bookmarks,
    tags: w.tags,
    categories: w.categories,
  );

  Wallpaper toDomain() => Wallpaper(
    id: id.toString(),
    title: title,
    description: content,
    imageUrl: imageUrl,
    thumbnailUrl: thumbnailImageUrl,
    videoUrl: videoUrl,
    width: imageWidth,
    height: imageHeight,
    tags: tags,
    categories: categories,
    stats: WallpaperStats(
      views: viewCount,
      downloads: downloadCount,
      bookmarks: bookmarkCount,
    ),
    createdAt:
        DateTime.tryParse(createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}
