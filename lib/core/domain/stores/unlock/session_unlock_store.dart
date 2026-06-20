import 'package:flutter_bloc/flutter_bloc.dart';
import 'session_unlock_state.dart';

/// Long-lived holder for wallpapers unlocked via a rewarded ad during the
/// current app session. Deliberately NOT persisted: an unlock lasts only until
/// the app is restarted, after which the wallpaper re-locks and must be
/// unlocked again.
///
/// Slot assignments (whether a wallpaper is rewarded vs interstitial) persist
/// separately via [AdPolicyRepository], so the gate stays stable across
/// launches even though the unlock itself does not.
class SessionUnlockStore extends Cubit<SessionUnlockState> {
  SessionUnlockStore()
      : super(const SessionUnlockState(unlockedIds: <String>{}));

  bool isUnlocked(String wallpaperId) =>
      state.unlockedIds.contains(wallpaperId);

  void markUnlocked(String wallpaperId) =>
      emit(state.copyWith(unlockedIds: {...state.unlockedIds, wallpaperId}));
}
