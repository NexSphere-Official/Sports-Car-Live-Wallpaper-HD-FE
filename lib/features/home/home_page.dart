import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/domain/models/wallpaper_filter.dart';
import 'home_cubit.dart';
import 'home_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
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
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
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
          childAspectRatio: 0.6,
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
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'THE SPORTS',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              _HeaderIcon(
                icon: Icons.favorite_border_rounded,
                onTap: onTapFavorites,
              ),
              const SizedBox(width: 2),
              _HeaderIcon(icon: Icons.tune_rounded, onTap: onTapSettings),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displayLarge,
                children: const [
                  TextSpan(text: 'Car live\n'),
                  TextSpan(
                    text: 'wallpaper.',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state, required this.onSelectType});

  final HomeState state;
  final ValueChanged<WallpaperType> onSelectType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: _Segmented<WallpaperType>(
        value: state.filter.type,
        options: const {
          WallpaperType.all: 'All',
          WallpaperType.live: 'Live',
          WallpaperType.still: 'HD',
        },
        onChanged: onSelectType,
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FilterHeaderDelegate({required this.state, required this.onSelectType});

  final HomeState state;
  final ValueChanged<WallpaperType> onSelectType;

  static const double _height = 60;

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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent
                ? context.palette.border
                : Colors.transparent,
          ),
        ),
      ),
      child: _FilterBar(state: state, onSelectType: onSelectType),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) =>
      oldDelegate.state.filter.type != state.filter.type;
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.palette.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.border),
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
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  entry.value,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: selected ? Colors.white : context.palette.textDim,
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
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.accent,
            ),
          ),
        ),
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
