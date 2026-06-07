import 'package:equatable/equatable.dart';

class WallpaperStats extends Equatable {
  final int views;
  final int downloads;
  final int bookmarks;

  const WallpaperStats({
    required this.views,
    required this.downloads,
    required this.bookmarks,
  });

  factory WallpaperStats.empty() =>
      const WallpaperStats(views: 0, downloads: 0, bookmarks: 0);

  WallpaperStats copyWith({int? views, int? downloads, int? bookmarks}) =>
      WallpaperStats(
        views: views ?? this.views,
        downloads: downloads ?? this.downloads,
        bookmarks: bookmarks ?? this.bookmarks,
      );

  @override
  List<Object?> get props => [views, downloads, bookmarks];
}
