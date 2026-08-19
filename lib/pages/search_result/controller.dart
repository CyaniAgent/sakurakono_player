import 'dart:async' show StreamController;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/models/search_types.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

class SearchResultState {
  const SearchResultState({
    required this.keyword,
    this.count = const [],
    this.toTopIndex = -1,
  });

  final String keyword;
  final List<int> count;
  final int toTopIndex;

  SearchResultState copyWith({
    String? keyword,
    List<int>? count,
    int? toTopIndex,
  }) {
    return SearchResultState(
      keyword: keyword ?? this.keyword,
      count: count ?? List<int>.from(this.count),
      toTopIndex: toTopIndex ?? this.toTopIndex,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SearchResultNotifier extends StateNotifier<SearchResultState> {
  SearchResultNotifier(String keyword)
      : super(SearchResultState(
          keyword: keyword,
          count: List.filled(CoreSearchType.values.length, -1),
        ));

  /// Broadcast stream for [toTopIndex] changes — used by the GetX bridge so
  /// adapter-based [SearchPanelController] can subscribe without Riverpod ref.
  final StreamController<int> _toTopIndexController =
      StreamController<int>.broadcast();

  Stream<int> get toTopIndexStream => _toTopIndexController.stream;

  // -- Public state accessors (avoids protected-state access from bridge) --

  /// Current count list snapshot.
  List<int> get currentCount => state.count;

  /// Current toTopIndex value.
  int get currentToTopIndex => state.toTopIndex;

  void setCount(int index, int value) {
    final newCount = List<int>.from(state.count);
    newCount[index] = value;
    state = state.copyWith(count: newCount);
  }

  void setToTopIndex(int index) {
    if (state.toTopIndex == index) {
      // Force-refresh: set to -1 then back so listeners always fire.
      state = state.copyWith(toTopIndex: -1);
    }
    state = state.copyWith(toTopIndex: index);
    _toTopIndexController.add(index);
  }

  @override
  void dispose() {
    _toTopIndexController.close();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Family provider keyed by the unique page tag (timestamp string).
final searchResultProvider = StateNotifierProvider.autoDispose
    .family<SearchResultNotifier, SearchResultState, String>(
  (ref, tag) => SearchResultNotifier(tag),
);

// ---------------------------------------------------------------------------
// GetX bridge for adapter compatibility
// ---------------------------------------------------------------------------

/// Backward-compatible wrapper that lets GetX-based adapter code
/// (e.g. [SearchPanelController]) interact with the Riverpod state.
///
/// Registered via [Get.put] with the same tag as the Riverpod family key so
/// that `Get.find<SearchResultController>(tag: tag)` still resolves.
class SearchResultController {
  SearchResultController(this.keyword, SearchResultNotifier notifier)
      : _notifier = notifier;

  final String keyword;
  final SearchResultNotifier _notifier;

  /// Current count values — read-only snapshot (mutations go through
  /// [updateCount] to trigger state rebuilds).
  List<int> get count => _notifier.currentCount;

  /// Stream of [toTopIndex] changes for subscription.
  Stream<int> get toTopIndex => _notifier.toTopIndexStream;

  /// Update the count for a specific search type index.
  void updateCount(int index, int value) {
    _notifier.setCount(index, value);
  }

  /// Update the toTopIndex value.
  void setToTopIndex(int index) {
    _notifier.setToTopIndex(index);
  }
}
