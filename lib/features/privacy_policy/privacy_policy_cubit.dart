import 'package:flutter_bloc/flutter_bloc.dart';
import 'privacy_policy_initial_params.dart';
import 'privacy_policy_navigator.dart';
import 'privacy_policy_state.dart';

class PrivacyPolicyCubit extends Cubit<PrivacyPolicyState> {
  final PrivacyPolicyInitialParams initialParams;
  final PrivacyPolicyNavigator navigator;

  PrivacyPolicyCubit(this.initialParams, this.navigator)
    : super(PrivacyPolicyState.initial(initialParams: initialParams));

  void onInit() {}

  void onPageStarted() => emit(state.copyWith(isLoading: true));

  void onProgress(int progress) => emit(state.copyWith(progress: progress));

  void onPageFinished() =>
      emit(state.copyWith(isLoading: false, progress: 100));

  void onTapBack() => navigator.close();
}
