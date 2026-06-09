import 'package:equatable/equatable.dart';
import 'wallpaper.dart';

/// A single page of wallpapers plus its opaque cursor pagination state.
class WallpaperPage extends Equatable {
  final List<Wallpaper> wallpapers;

  /// Pass back as `?cursor=` to fetch the next page; `null` on the last page.
  final String? nextCursor;
  final bool hasMore;

  const WallpaperPage({
    required this.wallpapers,
    required this.nextCursor,
    required this.hasMore,
  });

  factory WallpaperPage.empty() =>
      const WallpaperPage(wallpapers: [], nextCursor: null, hasMore: false);

  WallpaperPage copyWith({
    List<Wallpaper>? wallpapers,
    String? nextCursor,
    bool? hasMore,
  }) => WallpaperPage(
    wallpapers: wallpapers ?? this.wallpapers,
    nextCursor: nextCursor ?? this.nextCursor,
    hasMore: hasMore ?? this.hasMore,
  );

  @override
  List<Object?> get props => [wallpapers, nextCursor, hasMore];
}
