import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Callback signature for tab change events.
typedef OnTabChange = void Function(int index);

/// A Riverpod-based alternative to [MainController] for tab navigation state.
///
/// This is additive — the existing GetX [MainController] is untouched.
/// Holds only essential tab navigation state: current tab index, tab titles,
/// and a change callback.
class MainTabNavigationState {
  const MainTabNavigationState({
    this.currentTab = 0,
    this.tabTitles = const [],
    this.onTabChange,
  });

  final int currentTab;
  final List<String> tabTitles;
  final OnTabChange? onTabChange;

  MainTabNavigationState copyWith({
    int? currentTab,
    List<String>? tabTitles,
    OnTabChange? onTabChange,
  }) {
    return MainTabNavigationState(
      currentTab: currentTab ?? this.currentTab,
      tabTitles: tabTitles ?? this.tabTitles,
      onTabChange: onTabChange ?? this.onTabChange,
    );
  }
}

/// StateNotifier that manages the main tab navigation state.
class MainTabNavigationController extends StateNotifier<MainTabNavigationState> {
  MainTabNavigationController() : super(const MainTabNavigationState());

  /// Initialize the controller with tab titles and an optional default tab.
  void init({
    required List<String> tabTitles,
    int defaultTab = 0,
    OnTabChange? onTabChange,
  }) {
    state = state.copyWith(
      tabTitles: tabTitles,
      currentTab: defaultTab.clamp(0, tabTitles.length - 1),
      onTabChange: onTabChange,
    );
  }

  /// Switch to the tab at [index].
  ///
  /// Does nothing if the index is out of bounds or already selected.
  void switchTab(int index) {
    if (index < 0 || index >= state.tabTitles.length) return;
    if (index == state.currentTab) return;
    state = state.copyWith(currentTab: index);
    state.onTabChange?.call(index);
  }
}

/// Provider for the main tab navigation controller.
final mainTabNavigationProvider =
    StateNotifierProvider<MainTabNavigationController, MainTabNavigationState>(
  (ref) => MainTabNavigationController(),
);
