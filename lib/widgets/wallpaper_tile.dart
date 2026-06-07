import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/domain/models/wallpaper.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'live_tag.dart';

class WallpaperTile extends StatefulWidget {
  const WallpaperTile({
    super.key,
    required this.wallpaper,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.heroPrefix = 'home',
  });

  final Wallpaper wallpaper;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final String heroPrefix;

  @override
  State<WallpaperTile> createState() => _WallpaperTileState();
}

class _WallpaperTileState extends State<WallpaperTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.wallpaper;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: '${widget.heroPrefix}-${w.id}',
                child: CachedNetworkImage(
                  imageUrl: w.previewUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, _) =>
                      Container(color: context.palette.surfaceHigh),
                  errorWidget: (context, _, _) => Container(
                    color: context.palette.surfaceHigh,
                    child: Icon(
                      Icons.directions_car_outlined,
                      color: context.palette.textFaint,
                    ),
                  ),
                ),
              ),
              if (w.isLive)
                const Positioned(top: 10, left: 10, child: LiveTag()),
              Positioned(
                top: 8,
                right: 8,
                child: _FavoriteButton(
                  isFavorite: widget.isFavorite,
                  onTap: widget.onToggleFavorite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorite),
            size: 18,
            color: isFavorite ? AppColors.accent : Colors.white,
          ),
        ),
      ),
    );
  }
}
