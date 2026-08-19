import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

class LaterBaseState {
  const LaterBaseState({
    this.enableMultiSelect = false,
    this.checkedCount = 0,
    this.isPlayAll = false,
    List<int>? counts,
  }) : counts = counts ??
            const [-1, -1, -1]; // LaterViewType.values.length

  final bool enableMultiSelect;
  final int checkedCount;
  final bool isPlayAll;
  final List<int> counts;

  LaterBaseState copyWith({
    bool? enableMultiSelect,
    int? checkedCount,
    bool? isPlayAll,
    List<int>? counts,
  }) {
    return LaterBaseState(
      enableMultiSelect: enableMultiSelect ?? this.enableMultiSelect,
      checkedCount: checkedCount ?? this.checkedCount,
      isPlayAll: isPlayAll ?? this.isPlayAll,
      counts: counts ?? this.counts,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class LaterBaseNotifier extends StateNotifier<LaterBaseState> {
  LaterBaseNotifier() : super(LaterBaseState(isPlayAll: Pref.enablePlayAll));

  double dx = 0;

  void setEnableMultiSelect(bool value) {
    state = state.copyWith(enableMultiSelect: value);
  }

  void setCheckedCount(int value) {
    state = state.copyWith(checkedCount: value);
  }

  void updateCount(int index, int value) {
    final newCounts = List<int>.from(state.counts);
    newCounts[index] = value;
    state = state.copyWith(counts: newCounts);
  }

  void decrementCount(int index, [int amount = 1]) {
    final newCounts = List<int>.from(state.counts);
    newCounts[index] -= amount;
    state = state.copyWith(counts: newCounts);
  }

  void setIsPlayAll(bool isPlayAll) {
    if (state.isPlayAll == isPlayAll) return;
    state = state.copyWith(isPlayAll: isPlayAll);
    GStorage.setting.put(SettingBoxKey.enablePlayAll, isPlayAll);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final laterBaseProvider =
    StateNotifierProvider<LaterBaseNotifier, LaterBaseState>((ref) {
  return LaterBaseNotifier();
});
