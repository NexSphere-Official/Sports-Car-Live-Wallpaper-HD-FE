class AdsState {
  /// True once UMP consent permits ad requests AND the Mobile Ads SDK has
  /// initialized successfully.
  final bool canRequestAds;

  const AdsState({required this.canRequestAds});

  AdsState copyWith({bool? canRequestAds}) =>
      AdsState(canRequestAds: canRequestAds ?? this.canRequestAds);
}
