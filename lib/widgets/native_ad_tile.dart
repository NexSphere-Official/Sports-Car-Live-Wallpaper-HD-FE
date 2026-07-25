import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/data/repositories/google_native_ad_cache.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A full-width native ad card rendered with the SDK's medium template, themed
/// to match the app. Reserves its height with a placeholder while loading (so
/// loading in doesn't shift the feed), and collapses on failure.
///
/// ARCHITECTURE NOTE: unlike the full-screen formats (interstitial/rewarded/
/// app-open) which live behind [AdsService], a [NativeAd] is bound 1:1 to the
/// [AdWidget] that renders it. What this widget does NOT own any more is the
/// ad's lifetime: it renders whatever [NativeAdCache] holds for its [slot] and
/// asks the cache to fill an empty one. Owning the ad here meant scrolling a
/// slot out of the viewport's cache extent destroyed it and scrolling back
/// bought a replacement — several paid-for requests per impression. The ad unit
/// id and the enable/consent gating still come from config/[AdsStore] via the
/// cubit.
class NativeAdTile extends StatefulWidget {
  final String adUnitId;

  /// Index of this ad's position in the feed. Identifies the cache entry, so
  /// the same slot keeps the same ad across scrolls and rebuilds.
  final int slot;

  final GoogleNativeAdCache cache;

  const NativeAdTile({
    super.key,
    required this.adUnitId,
    required this.slot,
    required this.cache,
  });

  @override
  State<NativeAdTile> createState() => _NativeAdTileState();
}

class _NativeAdTileState extends State<NativeAdTile> {
  /// Medium template bounds are 320–400 logical px; keep within that range.
  /// The feed's scroll cache extent is aligned to this so a slot is built
  /// roughly one card-height before it scrolls in.
  static const _height = 350.0;
  static const _maxWidth = 400.0;

  NativeAdSlot? _slot;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolved here (not initState) — the template style reads the inherited
    // theme, which isn't available until dependencies are resolved.
    if (_slot != null) return;
    final slot = widget.cache.slotFor(widget.slot)
      ..attach()
      ..addListener(_onSlotChanged);
    _slot = slot;
    slot.ensureLoaded(
      adUnitId: widget.adUnitId,
      style: _templateStyle(context),
    );
  }

  void _onSlotChanged() {
    if (mounted) setState(() {});
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
    // Release our claim, but leave the ad in the cache for the next time this
    // slot scrolls back into view.
    _slot
      ?..removeListener(_onSlotChanged)
      ..detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slot = _slot;
    // Collapse only when the load failed — while loading we keep the reserved
    // height so the ad doesn't push the feed when it appears.
    if (slot == null || slot.hasFailed) return const SizedBox.shrink();

    final ad = slot.ad;
    final palette = context.palette;
    final content = (slot.isLoaded && ad != null)
        ? AdWidget(ad: ad)
        : DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surfaceHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
          );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: SizedBox(height: _height, width: double.infinity, child: content),
      ),
    );
  }
}
