class SessionUnlockState {
  /// Ids of wallpapers unlocked via a rewarded ad during the current app
  /// session. Not persisted — reset to empty on every launch.
  final Set<String> unlockedIds;

  const SessionUnlockState({required this.unlockedIds});

  SessionUnlockState copyWith({Set<String>? unlockedIds}) =>
      SessionUnlockState(unlockedIds: unlockedIds ?? this.unlockedIds);
}
