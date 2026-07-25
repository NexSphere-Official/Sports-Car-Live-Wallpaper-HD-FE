import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../core/domain/models/wallpaper.dart';
import 'wallpaper_detail_cubit.dart';
import 'wallpaper_detail_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_panel.dart';

class WallpaperDetailPage extends StatefulWidget {
  final WallpaperDetailCubit cubit;

  const WallpaperDetailPage({super.key, required this.cubit});

  @override
  State<WallpaperDetailPage> createState() => _WallpaperDetailPageState();
}

class _WallpaperDetailPageState extends State<WallpaperDetailPage>
    with WidgetsBindingObserver {
  WallpaperDetailCubit get cubit => widget.cubit;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cubit.onInit();
    _setupVideo(cubit.state.wallpaper);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // Returning from the native live-wallpaper preview triggers a resume; let
    // the cubit decide whether to confirm the result.
    if (lifecycleState == AppLifecycleState.resumed) {
      cubit.onAppResumed();
    }
  }

  void _setupVideo(Wallpaper wallpaper) {
    if (!wallpaper.isLive) return;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(wallpaper.videoUrl),
    );
    _videoController = controller;
    controller
      ..setLooping(true)
      ..setVolume(0)
      ..initialize()
          .then((_) {
            controller.play();
          })
          .catchError((_) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: BlocBuilder<WallpaperDetailCubit, WallpaperDetailState>(
        bloc: cubit,
        builder: (context, state) {
          final w = state.wallpaper;
          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: cubit.onToggleChrome,
                child: _buildVisual(w),
              ),
              AnimatedOpacity(
                opacity: state.showChrome ? 1 : 0,
                duration: const Duration(milliseconds: 240),
                child: IgnorePointer(
                  ignoring: !state.showChrome,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const _Scrim(),
                      SafeArea(
                        child: Column(
                          children: [
                            _TopBar(onBack: cubit.onTapBack),
                            const Spacer(),
                            _ActionBar(
                              onPreview: cubit.onTapPreview,
                              onPrimary: state.isLocked
                                  ? cubit.onTapUnlock
                                  : cubit.onTapApply,
                              isLocked: state.isLocked,
                              isBusy: state.isBusy,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Preview mode: a self-fading hint so the immersive view isn't a
              // dead end. Taps pass through to the toggle-chrome detector below.
              if (!state.showChrome) const _PreviewHint(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVisual(Wallpaper w) {
    final image = CachedNetworkImage(
      imageUrl: w.imageUrl.isNotEmpty ? w.imageUrl : w.previewUrl,
      fit: BoxFit.cover,
      placeholder: (context, _) => Container(color: AppColors.darkSurface),
      errorWidget: (context, _, _) => Container(color: AppColors.darkSurface),
    );

    final controller = _videoController;
    if (controller == null) {
      return Hero(tag: 'home-${w.id}', child: image);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(tag: 'home-${w.id}', child: image),
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (!value.isInitialized) return const SizedBox.shrink();
            return AnimatedOpacity(
              opacity: value.isInitialized ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: value.size.width,
                  height: value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4, 1.0],
          colors: [
            AppColors.darkBg.withValues(alpha: 0.5),
            Colors.transparent,
            AppColors.darkBg.withValues(alpha: 0.85),
          ],
        ),
      ),
    );
  }
}

/// A glass pill shown on entering preview that fades itself out, telling the
/// user how to leave the immersive view. Pointer-transparent so a tap anywhere
/// still toggles the chrome back on.
class _PreviewHint extends StatefulWidget {
  const _PreviewHint();

  @override
  State<_PreviewHint> createState() => _PreviewHintState();
}

class _PreviewHintState extends State<_PreviewHint> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: Duration(milliseconds: _visible ? 300 : 450),
            curve: Curves.easeOut,
            child: IgnorePointer(
              child: GlassPanel(
                borderRadius: 100,
                blur: 16,
                fill: Colors.white.withValues(alpha: 0.12),
                border: Colors.white.withValues(alpha: 0.22),
                padding: const EdgeInsets.fromLTRB(14, 9, 16, 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap anywhere to exit preview',
                      style: GoogleFonts.chakraPetch(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          _CircleButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 100,
      blur: 16,
      onTap: onTap,
      fill: Colors.white.withValues(alpha: 0.12),
      border: Colors.white.withValues(alpha: 0.22),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onPreview,
    required this.onPrimary,
    required this.isLocked,
    required this.isBusy,
  });

  final VoidCallback onPreview;
  final VoidCallback onPrimary;
  final bool isLocked;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
      child: Row(
        children: [
          Expanded(child: _PreviewButton(onTap: onPreview)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _ApplyButton(
              onTap: onPrimary,
              isLoading: isBusy,
              isLocked: isLocked,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  const _PreviewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 16,
      blur: 18,
      onTap: onTap,
      fill: Colors.white.withValues(alpha: 0.12),
      border: Colors.white.withValues(alpha: 0.25),
      child: SizedBox(
        height: 56,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'PREVIEW',
                style: GoogleFonts.chakraPetch(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({
    required this.onTap,
    required this.isLoading,
    required this.isLocked,
  });

  final VoidCallback onTap;
  final bool isLoading;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentSoft, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLocked
                        ? Icons.play_circle_fill_rounded
                        : Icons.wallpaper_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isLocked ? 'WATCH TO UNLOCK' : 'SET WALLPAPER',
                    style: GoogleFonts.chakraPetch(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
