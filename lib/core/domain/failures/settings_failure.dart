import 'displayable_failure.dart';

class SettingsFailure implements HasDisplayableFailure {
  const SettingsFailure.unknown([this.cause])
    : type = SettingsFailureType.unknown;

  final SettingsFailureType type;
  final Object? cause;

  @override
  DisplayableFailure displayableFailure() {
    switch (type) {
      case SettingsFailureType.unknown:
        return DisplayableFailure.commonError();
    }
  }

  @override
  String toString() => 'SettingsFailure{type: $type, cause: $cause}';
}

enum SettingsFailureType { unknown }
