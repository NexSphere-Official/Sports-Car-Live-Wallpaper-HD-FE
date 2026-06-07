import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/app_theme_mode.dart';
import 'settings_cubit.dart';
import 'settings_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  final SettingsCubit cubit;

  const SettingsPage({super.key, required this.cubit});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsCubit get cubit => widget.cubit;

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
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        bloc: cubit,
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                'APPEARANCE',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 12),
              _ThemeOption(
                label: 'System',
                description: 'Match your device theme',
                icon: Icons.brightness_auto_rounded,
                selected: state.mode == AppThemeMode.system,
                onTap: () => cubit.onSelectMode(AppThemeMode.system),
              ),
              _ThemeOption(
                label: 'Light',
                description: 'Showroom white',
                icon: Icons.light_mode_rounded,
                selected: state.mode == AppThemeMode.light,
                onTap: () => cubit.onSelectMode(AppThemeMode.light),
              ),
              _ThemeOption(
                label: 'Dark',
                description: 'Underground garage',
                icon: Icons.dark_mode_rounded,
                selected: state.mode == AppThemeMode.dark,
                onTap: () => cubit.onSelectMode(AppThemeMode.dark),
              ),
              const SizedBox(height: 32),
              Text('DATA', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.favorite_rounded,
                label: 'Clear bookmarks',
                description: state.favoritesCount == 0
                    ? 'No bookmarks saved'
                    : '${state.favoritesCount} saved',
                destructive: true,
                isLoading: state.isClearingFavorites,
                onTap: cubit.onTapClearFavorites,
              ),
              _ActionTile(
                icon: Icons.cleaning_services_rounded,
                label: 'Clear cache',
                description: 'Free up cached images & files',
                isLoading: state.isClearingCache,
                onTap: cubit.onTapClearCache,
              ),
              const SizedBox(height: 32),
              Text('ABOUT', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 12),
              _InfoRow(label: 'App', value: 'Sports Car Live Wallpaper'),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.palette.surfaceHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.accent : context.palette.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.14)
                      : context.palette.border.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.accent : context.palette.textDim,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.isLoading,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool isLoading;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.accent : context.palette.textDim;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.palette.surfaceHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: destructive
                      ? AppColors.accent.withValues(alpha: 0.14)
                      : context.palette.border.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.accent,
                  ),
                )
              else
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
