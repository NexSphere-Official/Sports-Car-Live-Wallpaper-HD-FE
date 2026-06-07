class DisplayableFailure {
  const DisplayableFailure({required this.title, required this.message});

  DisplayableFailure.commonError([String? message])
    : title = 'Error',
      message = message ?? 'Something went wrong, please try again later';

  final String title;
  final String message;
}

abstract class HasDisplayableFailure {
  DisplayableFailure displayableFailure();
}
