import 'displayable_failure.dart';

class SetWallpaperFailure implements HasDisplayableFailure {
  const SetWallpaperFailure.unknown([this.cause])
    : type = SetWallpaperFailureType.unknown;
  const SetWallpaperFailure.download([this.cause])
    : type = SetWallpaperFailureType.download;

  final SetWallpaperFailureType type;
  final Object? cause;

  @override
  DisplayableFailure displayableFailure() {
    switch (type) {
      case SetWallpaperFailureType.download:
        return const DisplayableFailure(
          title: 'Download failed',
          message: 'Could not download this wallpaper. Check your connection.',
        );
      case SetWallpaperFailureType.unknown:
        return const DisplayableFailure(
          title: 'Could not set wallpaper',
          message: 'Something went wrong while applying the wallpaper.',
        );
    }
  }

  @override
  String toString() => 'SetWallpaperFailure{type: $type, cause: $cause}';
}

enum SetWallpaperFailureType { unknown, download }
