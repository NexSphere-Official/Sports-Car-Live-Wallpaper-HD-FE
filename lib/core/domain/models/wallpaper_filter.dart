import 'package:equatable/equatable.dart';

enum WallpaperSort { latest, popular, random }

enum WallpaperType { all, still, live }

class WallpaperFilter extends Equatable {
  final WallpaperSort sort;
  final WallpaperType type;

  const WallpaperFilter({
    this.sort = WallpaperSort.random,
    this.type = WallpaperType.all,
  });

  bool get isRandom => sort == WallpaperSort.random;

  WallpaperFilter copyWith({WallpaperSort? sort, WallpaperType? type}) =>
      WallpaperFilter(sort: sort ?? this.sort, type: type ?? this.type);

  @override
  List<Object?> get props => [sort, type];
}
