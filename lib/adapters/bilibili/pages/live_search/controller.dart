import 'package:skf/adapters/bilibili/pages/live_search/child/controller.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class LiveSearchState {
  const LiveSearchState({
    this.hasData = false,
    this.counts = const [-1, -1],
  });

  final bool hasData;
  final List<int> counts;

  LiveSearchState copyWith({
    bool? hasData,
    List<int>? counts,
  }) {
    return LiveSearchState(
      hasData: hasData ?? this.hasData,
      counts: counts ?? this.counts,
    );
  }
}

class LiveSearchParams {
  const LiveSearchParams({required this.mid, required this.uname});

  final String? mid;
  final String? uname;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveSearchParams && mid == other.mid && uname == other.uname;

  @override
  int get hashCode => Object.hash(mid, uname);
}

class LiveSearchNotifier extends StateNotifier<LiveSearchState> {
  LiveSearchNotifier({required this.mid, required this.uname})
      : super(const LiveSearchState());

  final String? mid;
  final String? uname;
  final editingController = TextEditingController();
  final focusNode = FocusNode();

  List<int> get counts => state.counts;
  bool get hasData => state.hasData;

  void updateCount(int index, int value) {
    final newCounts = List<int>.from(state.counts);
    newCounts[index] = value;
    state = state.copyWith(counts: newCounts);
  }

  void setHasData(bool value) {
    state = state.copyWith(hasData: value);
  }

  void clearSearchData() {
    editingController.clear();
    state = state.copyWith(counts: [-1, -1], hasData: false);
    focusNode.requestFocus();
  }

  void submitSearch({
    required LiveSearchChildController roomCtr,
    required LiveSearchChildController userCtr,
  }) {
    if (editingController.text.isNotEmpty) {
      if (IdUtils.digitOnlyRegExp.hasMatch(editingController.text)) {
        PageUtils.toLiveRoom(int.parse(editingController.text));
      } else {
        state = state.copyWith(hasData: true);
        roomCtr
          ..scrollController.jumpToTop()
          ..onReload();
        userCtr
          ..scrollController.jumpToTop()
          ..onReload();
      }
    }
  }

  @override
  void dispose() {
    editingController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

final liveSearchProvider = StateNotifierProvider.autoDispose.family<
  LiveSearchNotifier,
  LiveSearchState,
  LiveSearchParams
>((ref, params) => LiveSearchNotifier(mid: params.mid, uname: params.uname));
