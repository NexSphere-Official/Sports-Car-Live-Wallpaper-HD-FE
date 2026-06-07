import 'displayable_failure.dart';

class GetWallpapersFailure implements HasDisplayableFailure {
  const GetWallpapersFailure.unknown([this.cause])
    : type = GetWallpapersFailureType.unknown;
  const GetWallpapersFailure.network([this.cause])
    : type = GetWallpapersFailureType.network;
  const GetWallpapersFailure.notFound([this.cause])
    : type = GetWallpapersFailureType.notFound;

  final GetWallpapersFailureType type;
  final Object? cause;

  @override
  DisplayableFailure displayableFailure() {
    switch (type) {
      case GetWallpapersFailureType.network:
        return const DisplayableFailure(
          title: 'No connection',
          message: 'Check your internet connection and try again.',
        );
      case GetWallpapersFailureType.notFound:
        return const DisplayableFailure(
          title: 'Not found',
          message: 'These wallpapers could not be found.',
        );
      case GetWallpapersFailureType.unknown:
        return DisplayableFailure.commonError();
    }
  }

  @override
  String toString() => 'GetWallpapersFailure{type: $type, cause: $cause}';
}

enum GetWallpapersFailureType { unknown, network, notFound }
