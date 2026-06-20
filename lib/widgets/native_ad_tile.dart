import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A full-width native ad card rendered with the SDK's medium template, themed
/// to match the app. Loads its own [NativeAd] once, reserves its height with a
/// placeholder while loading (so loading in doesn't shift the feed), and
/// collapses on failure.
class NativeAdTile extends StatefulWidget {
  final String adUnitId;

  const NativeAdTile({super.key, required this.adUnitId});

  @override
  State<NativeAdTile> createState() => _NativeAdTileState();
}

class _NativeAdTileState extends State<NativeAdTile> {
  /// Medium template bounds are 320–400 logical px; keep within that range.
  static const _height = 350.0;
  static const _maxWidth = 400.0;

  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _failed = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load once, here (not initState) — the template style reads the inherited
    // theme, which isn't available until dependencies are resolved.
    if (_requested) return;
    _requested = true;
    _loadAd();
  }

  void _loadAd() {
    final ad = NativeAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: _templateStyle(context),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _isLoaded = true);
          } else {
            _nativeAd?.dispose();
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _nativeAd = null;
              _failed = true;
            });
          }
        },
      ),
    );
    _nativeAd = ad;
    ad.load();
  }

  NativeTemplateStyle _templateStyle(BuildContext context) {
    final palette = context.palette;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return NativeTemplateStyle(
      templateType: TemplateType.medium,
      mainBackgroundColor: palette.surfaceHigh,
      cornerRadius: 16.0,
      callToActionTextStyle: NativeTemplateTextStyle(
        textColor: Colors.white,
        backgroundColor: AppColors.accent,
        style: NativeTemplateFontStyle.bold,
        size: 14.0,
      ),
      primaryTextStyle: NativeTemplateTextStyle(
        textColor: onSurface,
        style: NativeTemplateFontStyle.bold,
        size: 15.0,
      ),
      secondaryTextStyle: NativeTemplateTextStyle(
        textColor: palette.textDim,
        size: 13.0,
      ),
      tertiaryTextStyle: NativeTemplateTextStyle(
        textColor: palette.textFaint,
        size: 12.0,
      ),
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Collapse only when the load failed — while loading we keep the reserved
    // height so the ad doesn't push the feed when it appears.
    if (_failed) return const SizedBox.shrink();

    final ad = _nativeAd;
    final content = (_isLoaded && ad != null)
        ? AdWidget(ad: ad)
        : _Placeholder(palette: context.palette);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: SizedBox(height: _height, width: double.infinity, child: content),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
    );
  }
}
