import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Full-bleed looping video, scaled to cover its box (no letterboxing), muted,
/// with an optional [overlay] painted on top for legibility. While the first
/// frame decodes — or if playback fails — a solid [fallbackColor] is shown so
/// nothing ever flashes white.
class VideoBackground extends StatefulWidget {
  const VideoBackground({
    super.key,
    required this.asset,
    this.fallbackColor = Colors.black,
    this.overlay,
    this.child,
    this.loop = true,
  });

  /// Bundled asset path, e.g. `assets/splash.mp4`.
  final String asset;
  final Color fallbackColor;

  /// Painted over the video (e.g. a darkening scrim), below [child].
  final Widget? overlay;

  /// Foreground content stacked on top of the video and [overlay].
  final Widget? child;
  final bool loop;

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.asset)
      ..setVolume(0)
      ..setLooping(widget.loop);
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          _controller.play();
          setState(() => _ready = true);
        })
        .catchError((_) {
          // Leave the fallback color in place if the clip can't be decoded.
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.fallbackColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          if (widget.overlay != null) widget.overlay!,
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
