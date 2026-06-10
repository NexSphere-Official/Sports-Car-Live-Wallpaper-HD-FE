import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/branded_progress_bar.dart';
import '../splash_cubit.dart';
import '../splash_state.dart';

/// Bottom bootstrap readout: the current phase label, a smoothly counting
/// percentage, and the glowing [BrandedProgressBar]. Reads progress straight
/// from [SplashCubit].
class SplashProgressIndicator extends StatelessWidget {
  const SplashProgressIndicator({super.key, required this.cubit});

  final SplashCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashCubit, SplashState>(
      bloc: cubit,
      builder: (context, state) {
        final labelStyle = GoogleFonts.chakraPetch(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.statusLabel,
                  style: labelStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                // Count the percent up in step with the bar fill.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: state.progress.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => Text(
                    '${(t * 100).round().toString().padLeft(2, '0')}%',
                    style: labelStyle.copyWith(color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BrandedProgressBar(
              value: state.progress,
              height: 5,
              trackColor: Colors.white.withValues(alpha: 0.22),
            ),
          ],
        );
      },
    );
  }
}
