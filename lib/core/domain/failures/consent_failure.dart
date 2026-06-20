import 'displayable_failure.dart';

class ConsentFailure implements HasDisplayableFailure {
  const ConsentFailure.unknown([this.cause])
    : type = ConsentFailureType.unknown;

  final ConsentFailureType type;
  final Object? cause;

  @override
  DisplayableFailure displayableFailure() {
    switch (type) {
      case ConsentFailureType.unknown:
        return DisplayableFailure.commonError();
    }
  }

  @override
  String toString() => 'ConsentFailure{type: $type, cause: $cause}';
}

enum ConsentFailureType { unknown }
