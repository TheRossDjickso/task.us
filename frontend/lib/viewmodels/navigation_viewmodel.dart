import 'package:flutter_riverpod/flutter_riverpod.dart';

// ViewModel that manages the navigation index of the bottom bar.
// Controls which main screen is active in the app layout.
class NavigationViewModel extends StateNotifier<int> {
  NavigationViewModel() : super(0); // Projects (index 0) is active.

  // Changes the active navigation tab.
  void setIndex(int index) {
    state = index;
  }
}

// Global provider to expose the navigation state.
final navigationProvider =
    StateNotifierProvider<NavigationViewModel, int>((ref) {
  return NavigationViewModel();
});
