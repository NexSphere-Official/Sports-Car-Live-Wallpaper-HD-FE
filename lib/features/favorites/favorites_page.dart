import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_cubit.dart';
import 'favorites_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: cubit.onTapBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Bookmarked'),
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesPageState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.isLoading && state.favorites.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (state.isEmpty) {
            return _EmptyState();
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.6,
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
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 52,
              color: context.palette.textFaint,
            ),
            const SizedBox(height: 18),
            Text(
              'No bookmarks yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on any wallpaper to park it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
