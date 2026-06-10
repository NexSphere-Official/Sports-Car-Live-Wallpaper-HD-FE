import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../widgets/video_background.dart';
import 'splash_cubit.dart';
import 'widgets/splash_brand_badge.dart';
import 'widgets/splash_progress_indicator.dart';
import 'widgets/splash_reveal.dart';
import 'widgets/splash_scrim.dart';
import 'widgets/splash_wordmark.dart';

class SplashPage extends StatefulWidget {
  final SplashCubit cubit;

  const SplashPage({super.key, required this.cubit});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  SplashCubit get cubit => widget.cubit;

  // UI-only intro reveal — staggered fade/slide of the content layers.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void initState() {
    super.initState();
    cubit.onInit();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: VideoBackground(
          asset: 'assets/splash.mp4',
          fallbackColor: AppColors.darkBg,
          overlay: const SplashScrim(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SplashReveal(
                    controller: _intro,
                    start: 0.0,
                    child: const SplashBrandBadge(),
                  ),
                  const SizedBox(height: 20),
                  SplashReveal(
                    controller: _intro,
                    start: 0.15,
                    child: const SplashWordmark(),
                  ),
                  const Spacer(),
                  SplashReveal(
                    controller: _intro,
                    start: 0.35,
                    child: SplashProgressIndicator(cubit: cubit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
