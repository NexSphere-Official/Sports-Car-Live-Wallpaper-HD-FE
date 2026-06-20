import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shimmer.dart';

/// A grid of shimmering placeholder tiles matching the wallpaper grid layout,
/// shown while the first page loads. Returns a sliver.
class WallpaperGridShimmer extends StatelessWidget {
  const WallpaperGridShimmer({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final base = context.palette.surfaceHigh;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Shimmer(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.56,
            ),
            itemCount: itemCount,
            itemBuilder: (context, _) => DecoratedBox(
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
