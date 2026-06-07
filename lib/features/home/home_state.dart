import '../../core/domain/models/wallpaper.dart';
import '../../core/domain/models/wallpaper_filter.dart';
import 'home_initial_params.dart';

class HomeState {
  final WallpaperFilter filter;
  final List<Wallpaper> wallpapers;
  final Set<String> favoriteIds;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final bool hasError;

  bool get isEmpty => wallpapers.isEmpty && !isInitialLoading && !hasError;

  bool isFavorite(String id) => favoriteIds.contains(id);

  const HomeState({
    required this.filter,
    required this.wallpapers,
    required this.favoriteIds,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    required this.hasError,
  });

  factory HomeState.initial({required HomeInitialParams initialParams}) =>
      const HomeState(
        filter: WallpaperFilter(),
        wallpapers: [],
        favoriteIds: {},
        isInitialLoading: false,
        isLoadingMore: false,
        hasReachedEnd: false,
        hasError: false,
      );

  HomeState copyWith({
    WallpaperFilter? filter,
    List<Wallpaper>? wallpapers,
    Set<String>? favoriteIds,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? hasError,
  }) => HomeState(
    filter: filter ?? this.filter,
    wallpapers: wallpapers ?? this.wallpapers,
    favoriteIds: favoriteIds ?? this.favoriteIds,
    isInitialLoading: isInitialLoading ?? this.isInitialLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    hasError: hasError ?? this.hasError,
  );
}
