import 'displayable_failure.dart';

class AdsFailure implements HasDisplayableFailure {
  const AdsFailure.unknown([this.cause]) : type = AdsFailureType.unknown;
  const AdsFailure.initialization([this.cause])
    : type = AdsFailureType.initialization;

  final AdsFailureType type;
  final Object? cause;

  @override
  DisplayableFailure displayableFailure() {
    switch (type) {
      case AdsFailureType.initialization:
      case AdsFailureType.unknown:
        return DisplayableFailure.commonError();
    }
  }

  @override
  String toString() => 'AdsFailure{type: $type, cause: $cause}';
}

enum AdsFailureType { unknown, initialization }
