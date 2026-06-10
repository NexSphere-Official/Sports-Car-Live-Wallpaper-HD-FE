import 'splash_initial_params.dart';

class SplashState {
  /// Bootstrap progress, 0.0–1.0.
  final double progress;

  /// Short technical label describing the current bootstrap phase.
  final String statusLabel;

  const SplashState({required this.progress, required this.statusLabel});

  /// Integer percent for the readout, e.g. `87`.
  int get percent => (progress.clamp(0.0, 1.0) * 100).round();

  factory SplashState.initial({required SplashInitialParams initialParams}) =>
      const SplashState(progress: 0, statusLabel: 'IGNITION');

  SplashState copyWith({double? progress, String? statusLabel}) => SplashState(
    progress: progress ?? this.progress,
    statusLabel: statusLabel ?? this.statusLabel,
  );
}
