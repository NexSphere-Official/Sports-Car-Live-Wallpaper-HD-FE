/// Domain-facing handle on the feed's native ad store.
///
/// Rendering a native ad is inherently widget- and SDK-coupled, so the slot
/// lookup lives in the data layer with the concrete implementation. What the
/// domain needs is only the ability to release everything — when consent is
/// withdrawn or ads are switched off, no already-loaded ad may stay resident.
abstract class NativeAdCache {
  /// Release every cached ad. Entries still bound to a mounted widget are
  /// released as soon as that widget lets go.
  void clear();
}
