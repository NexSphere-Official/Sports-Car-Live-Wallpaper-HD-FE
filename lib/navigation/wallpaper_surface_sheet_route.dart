import 'package:flutter/material.dart';
import '../core/domain/models/wallpaper_surface.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_navigator.dart';

mixin WallpaperSurfaceSheetRoute {
  /// Asks the user where to apply a static wallpaper. Returns the chosen
  /// surface, or null if the sheet was dismissed.
  Future<WallpaperSurface?> askWallpaperSurface() {
    final context = AppNavigator.navigatorKey.currentContext!;
    return showModalBottomSheet<WallpaperSurface>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => const _WallpaperSurfaceSheet(),
    );
  }

  AppNavigator get appNavigator;
}

class _WallpaperSurfaceSheet extends StatelessWidget {
  const _WallpaperSurfaceSheet();

  @override
  Widget build(BuildContext context) {
    // showModalBottomSheet's useSafeArea pads top/left/right but NOT the
    // bottom, so add the navigation-bar inset ourselves to stop the last
    // option being clipped behind the system nav bar.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('SET WALLPAPER', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            'Where should it be applied?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          _Option(
            icon: Icons.home_rounded,
            label: 'Home screen',
            surface: WallpaperSurface.home,
          ),
          _Option(
            icon: Icons.lock_rounded,
            label: 'Lock screen',
            surface: WallpaperSurface.lock,
          ),
          _Option(
            icon: Icons.smartphone_rounded,
            label: 'Both screens',
            surface: WallpaperSurface.both,
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.label,
    required this.surface,
  });

  final IconData icon;
  final String label;
  final WallpaperSurface surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(surface),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: context.palette.surfaceHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.palette.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 22),
              const SizedBox(width: 14),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: context.palette.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
