import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/domain/models/app_theme_mode.dart';
import 'settings_cubit.dart';
import 'settings_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

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
      body: BlocBuilder<SettingsCubit, SettingsState>(
        bloc: cubit,
        builder: (context, state) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(onBack: cubit.onTapBack),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    children: [
                      const _SectionLabel('APPEARANCE'),
                      const SizedBox(height: 10),
                      _ThemeSegment(
                        mode: state.mode,
                        onSelect: cubit.onSelectMode,
                      ),
                      const SizedBox(height: 26),
                      const _SectionLabel('GENERAL'),
                      const SizedBox(height: 10),
                      _GroupCard(
                        children: [
                          _SettingRow(
                            icon: Icons.ios_share_rounded,
                            label: 'Share app',
                            onTap: cubit.onTapShare,
                          ),
                          _SettingRow(
                            icon: Icons.star_rounded,
                            label: 'Rate app',
                            onTap: cubit.onTapRate,
                          ),
                          _SettingRow(
                            icon: Icons.privacy_tip_rounded,
                            label: 'Privacy policy',
                            onTap: cubit.onTapPrivacy,
                            showDivider: state.isPrivacyOptionsRequired,
                          ),
                          if (state.isPrivacyOptionsRequired)
                            _SettingRow(
                              icon: Icons.tune_rounded,
                              label: 'Privacy options',
                              onTap: cubit.onTapPrivacyOptions,
                              showDivider: false,
                            ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      const _SectionLabel('DATA'),
                      const SizedBox(height: 10),
                      _GroupCard(
                        children: [
                          _SettingRow(
                            icon: Icons.favorite_rounded,
                            label: 'Clear bookmarks',
                            tint: AppColors.accent,
                            isLoading: state.isClearingFavorites,
                            onTap: cubit.onTapClearFavorites,
                          ),
                          _SettingRow(
                            icon: Icons.cleaning_services_rounded,
                            label: 'Clear cache',
                            isLoading: state.isClearingCache,
                            onTap: cubit.onTapClearCache,
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _VersionFooter(version: state.version),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
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
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineMedium,
              children: const [
                TextSpan(text: 'Settings'),
                TextSpan(text: '.', style: TextStyle(color: AppColors.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelMedium);
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({required this.mode, required this.onSelect});

  final AppThemeMode mode;
  final ValueChanged<AppThemeMode> onSelect;

  static const _options = <AppThemeMode, ({IconData icon, String label})>{
    AppThemeMode.system: (icon: Icons.brightness_auto_rounded, label: 'System'),
    AppThemeMode.light: (icon: Icons.light_mode_rounded, label: 'Light'),
    AppThemeMode.dark: (icon: Icons.dark_mode_rounded, label: 'Dark'),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.palette.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.palette.border),
      ),
      child: Row(
        children: _options.entries.map((entry) {
          final selected = entry.key == mode;
          final option = entry.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      option.icon,
                      size: 20,
                      color: selected
                          ? Colors.white
                          : context.palette.textDim,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.label,
                      style: GoogleFonts.chakraPetch(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: selected
                            ? Colors.white
                            : context.palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
    this.isLoading = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint;
  final bool isLoading;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? context.palette.textDim;
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (tint ?? context.palette.border).withValues(
                      alpha: tint != null ? 0.14 : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 19, color: color),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
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
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 63,
            color: context.palette.border,
          ),
      ],
    );
  }
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    if (version.isEmpty) return const SizedBox(height: 8);
    return Center(
      child: Text(
        'VERSION $version',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
