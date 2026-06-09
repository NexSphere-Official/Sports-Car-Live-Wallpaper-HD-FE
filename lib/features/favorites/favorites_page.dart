import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_cubit.dart';
import 'favorites_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncing_dots.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/wallpaper_tile.dart';

class FavoritesPage extends StatefulWidget {
  final FavoritesCubit cubit;

  const FavoritesPage({super.key, required this.cubit});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  FavoritesCubit get cubit => widget.cubit;

  @override
  void initState() {
    super.initState();
    cubit.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FavoritesCubit, FavoritesPageState>(
        bloc: cubit,
        builder: (context, state) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _FavHeader(count: state.favorites.length, onBack: cubit.onTapBack),
                Expanded(child: _buildBody(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(FavoritesPageState state) {
    if (state.isLoading && state.favorites.isEmpty) {
      return const Center(child: BouncingDots());
    }
    if (state.isEmpty) {
      return const _EmptyState();
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.56,
      ),
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final wallpaper = state.favorites[index];
        return WallpaperTile(
          wallpaper: wallpaper,
          heroPrefix: 'fav',
          isFavorite: true,
          onToggleFavorite: () => cubit.onToggleFavorite(wallpaper),
          onTap: () => cubit.onTapWallpaper(wallpaper),
        );
      },
    );
  }
}

class _FavHeader extends StatelessWidget {
  const _FavHeader({required this.count, required this.onBack});

  final int count;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GlassPanel(
            borderRadius: 100,
            blur: 14,
            onTap: onBack,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count == 0 ? 'YOUR GARAGE' : '$count SAVED',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium,
                  children: const [
                    TextSpan(text: 'Saved'),
                    TextSpan(
                      text: '.',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassPanel(
              borderRadius: 100,
              blur: 12,
              padding: const EdgeInsets.all(24),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 40,
                color: context.palette.textFaint,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No bookmarks yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on any wallpaper to park it in your garage.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
