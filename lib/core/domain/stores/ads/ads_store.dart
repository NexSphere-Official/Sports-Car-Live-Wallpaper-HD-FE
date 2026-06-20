import 'package:flutter_bloc/flutter_bloc.dart';
import 'ads_state.dart';

/// Long-lived holder for runtime ad readiness. Set by GatherAdsConsentUseCase
/// at startup (true only when consent permits ads and the SDK initialized), and
/// read by features before rendering/requesting ads.
class AdsStore extends Cubit<AdsState> {
  AdsStore() : super(const AdsState(canRequestAds: false));

  bool get canRequestAds => state.canRequestAds;

  void setCanRequestAds(bool value) =>
      emit(state.copyWith(canRequestAds: value));
}
