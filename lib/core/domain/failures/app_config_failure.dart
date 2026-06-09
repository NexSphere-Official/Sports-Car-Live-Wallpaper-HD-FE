import 'displayable_failure.dart';

class AppConfigFailure implements HasDisplayableFailure {
  const AppConfigFailure.unknown([this.cause])
    : type = AppConfigFailureType.unknown;
  const AppConfigFailure.fetch([this.cause]) : type = AppConfigFailureType.fetch;
  const AppConfigFailure.parse([this.cause]) : type = AppConfigFailureType.parse;

  final AppConfigFailureType type;
  final Object? cause;

  @override
  DisplayableFailure displayableFailure() {
    switch (type) {
      case AppConfigFailureType.fetch:
        return const DisplayableFailure(
          title: 'No connection',
          message: 'Could not load configuration. Check your connection.',
        );
      case AppConfigFailureType.parse:
      case AppConfigFailureType.unknown:
        return DisplayableFailure.commonError();
    }
  }

  @override
  String toString() => 'AppConfigFailure{type: $type, cause: $cause}';
}

enum AppConfigFailureType { unknown, fetch, parse }
