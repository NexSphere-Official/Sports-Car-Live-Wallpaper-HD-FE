import 'package:equatable/equatable.dart';

class WallpaperCategory extends Equatable {
  final int id;
  final String name;
  final String slug;

  const WallpaperCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory WallpaperCategory.empty() =>
      const WallpaperCategory(id: 0, name: '', slug: '');

  WallpaperCategory copyWith({int? id, String? name, String? slug}) =>
      WallpaperCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
      );

  @override
  List<Object?> get props => [id];
}
