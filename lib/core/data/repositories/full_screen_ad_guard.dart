/// Shared in-memory coordinator for full-screen ads (interstitial, rewarded,
/// app-open). Prevents two full-screen ads from overlapping and tracks when the
/// last one was shown so cooldowns apply across every placement.
///
/// In-memory by design: the cooldown windows are short, so resetting on app
/// restart is acceptable.
class FullScreenAdGuard {
  bool _isShowing = false;
  DateTime? _lastShownAt;

  /// True while any full-screen ad is on screen.
  bool get isShowing => _isShowing;

  void markShown() {
    _isShowing = true;
    _lastShownAt = DateTime.now();
  }

  void markDismissed() => _isShowing = false;

  /// Whether we're still within [cooldown] of the last full-screen ad.
  bool withinCooldown(Duration cooldown) {
    if (cooldown <= Duration.zero) return false;
    final last = _lastShownAt;
    return last != null && DateTime.now().difference(last) < cooldown;
  }
}
