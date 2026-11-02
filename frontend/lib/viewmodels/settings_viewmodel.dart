import 'package:flutter_riverpod/flutter_riverpod.dart';

// State representing the user's settings.
class SettingsState {
  final bool pushNotificationsEnabled;
  final bool remindersEnabled;

  const SettingsState({
    this.pushNotificationsEnabled = true,
    this.remindersEnabled = true,
  });

  SettingsState copyWith({
    bool? pushNotificationsEnabled,
    bool? remindersEnabled,
  }) {
    return SettingsState(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

// ViewModel managing the settings state.
class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel() : super(const SettingsState());

  void togglePushNotifications() {
    state = state.copyWith(pushNotificationsEnabled: !state.pushNotificationsEnabled);
  }

  void toggleReminders() {
    state = state.copyWith(remindersEnabled: !state.remindersEnabled);
  }

  void logOut() {
    // Add logout logic here later if needed.
    // For now, it just serves as a mock action.
  }
}

// Global provider for the SettingsViewModel.
final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel();
});
