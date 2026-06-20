import '../../core/domain/models/wallpaper.dart';
import '../../core/domain/models/wallpaper_type.dart';
import 'home_initial_params.dart';

class HomeState {
  final WallpaperType type;
  final List<Wallpaper> wallpapers;
  final Set<String> favoriteIds;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final bool hasError;
  final String? nextCursor;

  /// Native ad placement, resolved from Remote Config at init.
  final bool nativeAdsEnabled;
  final String nativeAdUnitId;
  final int nativeAdInterval;

  bool get isEmpty => wallpapers.isEmpty && !isInitialLoading && !hasError;

  bool isFavorite(String id) => favoriteIds.contains(id);

  const HomeState({
    required this.type,
    required this.wallpapers,
    required this.favoriteIds,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    required this.hasError,
    required this.nextCursor,
    required this.nativeAdsEnabled,
    required this.nativeAdUnitId,
    required this.nativeAdInterval,
  });

  factory HomeState.initial({required HomeInitialParams initialParams}) =>
      const HomeState(
        type: WallpaperType.all,
        wallpapers: [],
        favoriteIds: {},
        isInitialLoading: false,
        isLoadingMore: false,
        hasReachedEnd: false,
        hasError: false,
        nextCursor: null,
        nativeAdsEnabled: false,
        nativeAdUnitId: '',
        nativeAdInterval: 8,
      );

  HomeState copyWith({
    WallpaperType? type,
    List<Wallpaper>? wallpapers,
    Set<String>? favoriteIds,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? hasError,
    String? nextCursor,
    bool? nativeAdsEnabled,
    String? nativeAdUnitId,
    int? nativeAdInterval,
  }) => HomeState(
    type: type ?? this.type,
    wallpapers: wallpapers ?? this.wallpapers,
    favoriteIds: favoriteIds ?? this.favoriteIds,
    isInitialLoading: isInitialLoading ?? this.isInitialLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    hasError: hasError ?? this.hasError,
    nextCursor: nextCursor ?? this.nextCursor,
    nativeAdsEnabled: nativeAdsEnabled ?? this.nativeAdsEnabled,
    nativeAdUnitId: nativeAdUnitId ?? this.nativeAdUnitId,
    nativeAdInterval: nativeAdInterval ?? this.nativeAdInterval,
  );
}
