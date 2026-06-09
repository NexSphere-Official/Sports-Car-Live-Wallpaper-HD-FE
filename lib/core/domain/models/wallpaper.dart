import 'package:equatable/equatable.dart';
import 'wallpaper_kind.dart';

/// A single wallpaper, mirroring the Sports Car Wallpaper API object:
/// `{ id, type, url, thumbnail, created_at }`.
///
/// - **still** → [url] is a `.webp` image, [thumbnail] is `.webp`.
/// - **live**  → [url] is an `.mp4` video, [thumbnail] is `.webp` (poster).
class Wallpaper extends Equatable {
  final String id;
  final WallpaperKind kind;
  final String url;
  final String thumbnail;
  final DateTime createdAt;

  const Wallpaper({
    required this.id,
    required this.kind,
    required this.url,
    required this.thumbnail,
    required this.createdAt,
  });

  bool get isLive => kind == WallpaperKind.live;

  /// Cheap preview asset for grids — always the `.webp` thumbnail.
  String get previewUrl => thumbnail.isNotEmpty ? thumbnail : url;

  /// Full image for static wallpapers; empty for live ones.
  String get imageUrl => isLive ? '' : url;

  /// Video source for live wallpapers; empty for static ones.
  String get videoUrl => isLive ? url : '';

  factory Wallpaper.empty() => Wallpaper(
    id: '',
    kind: WallpaperKind.still,
    url: '',
    thumbnail: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  Wallpaper copyWith({
    String? id,
    WallpaperKind? kind,
    String? url,
    String? thumbnail,
    DateTime? createdAt,
  }) => Wallpaper(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    url: url ?? this.url,
    thumbnail: thumbnail ?? this.thumbnail,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [id];
}
