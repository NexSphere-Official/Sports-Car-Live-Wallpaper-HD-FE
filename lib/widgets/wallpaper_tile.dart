import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/domain/models/wallpaper.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';
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
                child: FavoriteButton(
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
