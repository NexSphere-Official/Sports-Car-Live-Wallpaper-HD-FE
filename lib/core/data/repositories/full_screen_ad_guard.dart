/// Shared in-memory coordinator for full-screen ads (interstitial, rewarded,
/// app-open). Prevents two full-screen ads from overlapping and tracks when the
/// last one was shown so cooldowns apply across every placement.
///
/// Reservation model: callers [reserve] the single slot synchronously right
/// before calling `show()`, then [markShown] when it appears and [release] when
/// it's dismissed or fails to show. Because Dart is single-threaded and
/// [reserve] has no `await`, two placements can't both acquire the slot.
///
/// In-memory by design: the cooldown windows are short, so resetting on app
/// restart is acceptable.
class FullScreenAdGuard {
  bool _reserved = false;
  DateTime? _lastShownAt;

  /// True while the slot is reserved or a full-screen ad is on screen.
  bool get isShowing => _reserved;

  /// Atomically claim the single full-screen slot. Returns false if it's
  /// already reserved/showing — the caller must NOT show in that case.
  bool reserve() {
    if (_reserved) return false;
    _reserved = true;
    return true;
  }

  /// Stamp the shown time — call from `onAdShowedFullScreenContent`.
  void markShown() => _lastShownAt = DateTime.now();

  /// Release the slot — call on dismiss or failure-to-show.
  void release() => _reserved = false;

  /// Whether we're still within [cooldown] of the last full-screen ad.
  bool withinCooldown(Duration cooldown) {
    if (cooldown <= Duration.zero) return false;
    final last = _lastShownAt;
    return last != null && DateTime.now().difference(last) < cooldown;
  }
}
