import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/repositories/native_ad_cache.dart';

/// Session cache of loaded native ads, keyed by their slot index in the feed.
///
/// WHY THIS EXISTS: a [NativeAd] used to be owned by the widget that rendered
/// it, so scrolling a slot past the viewport's cache extent destroyed the
/// element, disposed the ad, and scrolling back issued a brand new request.
/// Normal up-and-down browsing therefore produced several requests per
/// impression. Slot N now keeps the ad it already paid for.
///
/// Bounded on both axes so this doesn't become a leak: at most [maxEntries]
/// ads are retained (least-recently-used first, and never one that a mounted
/// widget is still rendering), and an ad older than [ttl] is reloaded rather
/// than shown stale.
class GoogleNativeAdCache implements NativeAdCache {
  GoogleNativeAdCache({
    this.maxEntries = 8,
    this.ttl = const Duration(minutes: 50),
  });

  /// Upper bound on retained ads. Comfortably more than can be on screen at
  /// once, so scrolling back a screen or two still hits the cache.
  final int maxEntries;

  /// Native ads should not be displayed indefinitely; past this age a slot
  /// reloads on its next build.
  final Duration ttl;

  final Map<int, NativeAdSlot> _slots = {};

  /// Least-recently-touched first.
  final List<int> _lru = [];

  /// The (lazily created) cache entry for [slot]. Never null — the caller then
  /// drives it with [NativeAdSlot.attach] / [NativeAdSlot.ensureLoaded].
  NativeAdSlot slotFor(int slot) {
    final existing = _slots[slot];
    if (existing != null) {
      _touch(slot);
      return existing;
    }
    final created = NativeAdSlot._(ttl);
    // A slot released later (a pending [clear] landing when its widget lets go)
    // must leave the map too, or [slotFor] would keep handing back a dead entry
    // that can never load again.
    created._onDisposed = () => _forget(slot, created);
    _slots[slot] = created;
    _touch(slot);
    _evictIfNeeded();
    return created;
  }

  void _forget(int slot, NativeAdSlot entry) {
    if (!identical(_slots[slot], entry)) return;
    _slots.remove(slot);
    _lru.remove(slot);
  }

  void _touch(int slot) {
    _lru
      ..remove(slot)
      ..add(slot);
  }

  /// Drops the least-recently-used entries down to [maxEntries]. Entries a
  /// widget is currently rendering are skipped — disposing an ad still bound to
  /// a live `AdWidget` would crash the platform view.
  void _evictIfNeeded() {
    if (_slots.length <= maxEntries) return;
    for (final slot in List<int>.from(_lru)) {
      if (_slots.length <= maxEntries) return;
      final entry = _slots[slot];
      if (entry == null || entry._isAttached) continue;
      entry._dispose();
      _slots.remove(slot);
      _lru.remove(slot);
    }
  }

  /// Releases every cached ad — used when consent is withdrawn or ads are
  /// turned off, so nothing stays resident that we may no longer show. Entries
  /// still attached to a mounted widget are released as soon as they detach.
  @override
  void clear() {
    // Snapshot first: releasing an entry calls back into [_forget], which
    // mutates the very collections being walked.
    for (final entry in List<NativeAdSlot>.from(_slots.values)) {
      if (entry._isAttached) {
        entry._disposeOnDetach = true;
      } else {
        entry._dispose();
      }
    }
  }
}

/// One feed slot's ad and its load state. Notifies listeners whenever that
/// state changes so the rendering widget can rebuild.
class NativeAdSlot extends ChangeNotifier {
  NativeAdSlot._(this._ttl);

  final Duration _ttl;

  NativeAd? _ad;
  bool _isLoaded = false;
  bool _hasFailed = false;
  bool _isLoading = false;
  bool _isAttached = false;
  bool _disposeOnDetach = false;
  bool _isDisposed = false;
  DateTime? _loadedAt;

  /// Set by [GoogleNativeAdCache] so a release initiated from the entry side
  /// also drops it from the cache's maps.
  VoidCallback? _onDisposed;

  /// The loaded ad, or null while loading/failed. Only safe to hand to an
  /// `AdWidget` when [isLoaded] is true.
  NativeAd? get ad => _ad;

  bool get isLoaded => _isLoaded;

  /// True when the last attempt returned an error. The slot stays collapsed
  /// rather than retrying, so one no-fill can't turn into a request loop.
  bool get hasFailed => _hasFailed;

  /// Marks the slot as rendered by a mounted widget, which pins it against
  /// eviction.
  void attach() => _isAttached = true;

  void detach() {
    _isAttached = false;
    if (_disposeOnDetach) _dispose();
  }

  /// Starts a load if this slot has no usable ad. A slot that already holds a
  /// fresh ad, is mid-load, or has already failed does nothing — this is what
  /// makes scrolling back over a slot free.
  void ensureLoaded({
    required String adUnitId,
    required NativeTemplateStyle style,
  }) {
    if (_isDisposed || _isLoading || _hasFailed) return;
    if (_isLoaded && !_isExpired) return;

    if (_isLoaded && _isExpired) _releaseAd();

    _isLoading = true;
    final ad = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: style,
      listener: NativeAdListener(
        onAdLoaded: (loaded) {
          _isLoading = false;
          // Disposed while the request was in flight — don't retain it.
          if (_isDisposed) {
            loaded.dispose();
            return;
          }
          _isLoaded = true;
          _loadedAt = DateTime.now();
          _notify();
        },
        onAdFailedToLoad: (failed, error) {
          _isLoading = false;
          failed.dispose();
          if (_isDisposed) return;
          _ad = null;
          _isLoaded = false;
          _hasFailed = true;
          _notify();
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  bool get _isExpired {
    final loadedAt = _loadedAt;
    return loadedAt != null && DateTime.now().difference(loadedAt) > _ttl;
  }

  void _releaseAd() {
    _ad?.dispose();
    _ad = null;
    _isLoaded = false;
    _loadedAt = null;
  }

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  void _dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _releaseAd();
    _onDisposed?.call();
    // Lifetime belongs to [NativeAdCache], not to the widget rendering the
    // slot — widgets attach/detach instead of disposing.
    super.dispose();
  }
}
