import 'privacy_policy_initial_params.dart';

class PrivacyPolicyState {
  final bool isLoading;
  final int progress;

  const PrivacyPolicyState({required this.isLoading, required this.progress});

  factory PrivacyPolicyState.initial({
    required PrivacyPolicyInitialParams initialParams,
  }) => const PrivacyPolicyState(isLoading: true, progress: 0);

  PrivacyPolicyState copyWith({bool? isLoading, int? progress}) =>
      PrivacyPolicyState(
        isLoading: isLoading ?? this.isLoading,
        progress: progress ?? this.progress,
      );
}
