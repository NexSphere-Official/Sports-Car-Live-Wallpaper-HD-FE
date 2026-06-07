import 'package:equatable/equatable.dart';
import 'wallpaper_category.dart';
import 'wallpaper_stats.dart';

class Wallpaper extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final String videoUrl;
  final int width;
  final int height;
  final List<String> tags;
  final List<WallpaperCategory> categories;
  final WallpaperStats stats;
  final DateTime createdAt;

  const Wallpaper({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.width,
    required this.height,
    required this.tags,
    required this.categories,
    required this.stats,
    required this.createdAt,
  });

  bool get isLive => videoUrl.isNotEmpty;

  double get aspectRatio => (width > 0 && height > 0) ? width / height : 0.66;

  String get previewUrl => thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;

  factory Wallpaper.empty() => Wallpaper(
    id: '',
    title: '',
    description: '',
    imageUrl: '',
    thumbnailUrl: '',
    videoUrl: '',
    width: 0,
    height: 0,
    tags: const [],
    categories: const [],
    stats: WallpaperStats.empty(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  Wallpaper copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? thumbnailUrl,
    String? videoUrl,
    int? width,
    int? height,
    List<String>? tags,
    List<WallpaperCategory>? categories,
    WallpaperStats? stats,
    DateTime? createdAt,
  }) => Wallpaper(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    videoUrl: videoUrl ?? this.videoUrl,
    width: width ?? this.width,
    height: height ?? this.height,
    tags: tags ?? this.tags,
    categories: categories ?? this.categories,
    stats: stats ?? this.stats,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [id];
}
