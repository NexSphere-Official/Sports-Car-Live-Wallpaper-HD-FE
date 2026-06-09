import 'displayable_failure.dart';

class AppInfoFailure implements HasDisplayableFailure {
  const AppInfoFailure.unknown([this.cause])
    : type = AppInfoFailureType.unknown;

  final AppInfoFailureType type;
  final Object? cause;

  @override
  DisplayableFailure displayableFailure() {
    switch (type) {
      case AppInfoFailureType.unknown:
        return DisplayableFailure.commonError();
    }
  }

  @override
  String toString() => 'AppInfoFailure{type: $type, cause: $cause}';
}

enum AppInfoFailureType { unknown }
