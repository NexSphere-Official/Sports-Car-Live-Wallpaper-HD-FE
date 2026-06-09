import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/domain/models/wallpaper_type.dart';
import 'home_cubit.dart';
import 'home_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncing_dots.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/wallpaper_tile.dart';

class HomePage extends StatefulWidget {
  final HomeCubit cubit;

  const HomePage({super.key, required this.cubit});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeCubit get cubit => widget.cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    cubit.onInit();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 600) {
      cubit.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: cubit,
        builder: (context, state) {
          return SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: context.palette.surfaceHigh,
              onRefresh: cubit.onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeaderBlock(
                      onTapFavorites: cubit.onTapFavorites,
                      onTapSettings: cubit.onTapSettings,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _FilterHeaderDelegate(
                      state: state,
                      onSelectType: cubit.onSelectType,
                      background: Theme.of(context).scaffoldBackgroundColor,
                      surfaceHigh: context.palette.surfaceHigh,
                      border: context.palette.border,
                      textDim: context.palette.textDim,
                    ),
                  ),
                  _buildBody(context, state),
                  SliverToBoxAdapter(child: _Footer(state: state)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state.isInitialLoading) {
      return const WallpaperGridShimmer();
    }
    if (state.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _Message(
          icon: Icons.wifi_off_rounded,
          title: 'Engine stalled',
          subtitle: 'We couldn\'t reach the garage. Pull to retry.',
        ),
      );
    }
    if (state.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _Message(
          icon: Icons.search_off_rounded,
          title: 'Nothing in this lane',
          subtitle: 'Try a different filter.',
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.56,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final wallpaper = state.wallpapers[index];
          return TweenAnimationBuilder<double>(
            key: ValueKey(wallpaper.id),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 350 + (index % 6) * 60),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Opacity(
              opacity: t.clamp(0, 1),
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 24),
                child: child,
              ),
            ),
            child: WallpaperTile(
              wallpaper: wallpaper,
              isFavorite: state.isFavorite(wallpaper.id),
              onToggleFavorite: () => cubit.onToggleFavorite(wallpaper),
              onTap: () => cubit.onTapWallpaper(wallpaper),
            ),
          );
        }, childCount: state.wallpapers.length),
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({
    required this.onTapFavorites,
    required this.onTapSettings,
  });

  final VoidCallback onTapFavorites;
  final VoidCallback onTapSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CURATED · LIVE & HD',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(width: 10),
              _GlassChip(
                icon: Icons.favorite_rounded,
                label: 'Saved',
                onTap: onTapFavorites,
              ),
              const SizedBox(width: 8),
              _GlassChip(
                icon: Icons.tune_rounded,
                label: 'Settings',
                onTap: onTapSettings,
              ),
            ],
          ),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.displayLarge,
              children: const [
                TextSpan(text: 'Discover'),
                TextSpan(
                  text: '.',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GlassPanel(
      borderRadius: 100,
      blur: 14,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(11, 8, 14, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: onSurface),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.chakraPetch(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.state,
    required this.onSelectType,
    required this.surfaceHigh,
    required this.border,
    required this.textDim,
  });

  final HomeState state;
  final ValueChanged<WallpaperType> onSelectType;
  final Color surfaceHigh;
  final Color border;
  final Color textDim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _Segmented<WallpaperType>(
        value: state.type,
        options: const {
          WallpaperType.all: 'All',
          WallpaperType.live: 'Live',
          WallpaperType.still: 'HD',
        },
        onChanged: onSelectType,
        surfaceHigh: surfaceHigh,
        border: border,
        textDim: textDim,
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FilterHeaderDelegate({
    required this.state,
    required this.onSelectType,
    required this.background,
    required this.surfaceHigh,
    required this.border,
    required this.textDim,
  });

  final HomeState state;
  final ValueChanged<WallpaperType> onSelectType;

  // Colors are resolved at the HomePage context (which always reflects the
  // active theme) and painted directly here — the pinned header's own context
  // can lag a theme switch, so we never read Theme.of() inside this delegate.
  final Color background;
  final Color surfaceHigh;
  final Color border;
  final Color textDim;

  static const double _height = 56;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Translucent so the wallpapers scrolling beneath blur through.
            color: background.withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(
                color: overlapsContent ? border : Colors.transparent,
              ),
            ),
          ),
          child: _FilterBar(
            state: state,
            onSelectType: onSelectType,
            surfaceHigh: surfaceHigh,
            border: border,
            textDim: textDim,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) =>
      oldDelegate.state.type != state.type ||
      oldDelegate.background != background ||
      oldDelegate.surfaceHigh != surfaceHigh ||
      oldDelegate.border != border ||
      oldDelegate.textDim != textDim;
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.surfaceHigh,
    required this.border,
    required this.textDim,
  });

  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final Color surfaceHigh;
  final Color border;
  final Color textDim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: options.entries.map((entry) {
          final selected = entry.key == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  entry.value,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: selected ? Colors.white : textDim,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: BouncingDots()),
      );
    }
    if (state.hasReachedEnd && state.wallpapers.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            '— END OF THE LINE —',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: context.palette.textFaint),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
