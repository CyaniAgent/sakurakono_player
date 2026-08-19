import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

class ReplySearchState {
  const ReplySearchState({
    required this.type,
    required this.oid,
  });

  final int type;
  final int oid;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ReplySearchNotifier extends StateNotifier<ReplySearchState> {
  ReplySearchNotifier({required int type, required int oid})
      : super(ReplySearchState(type: type, oid: oid));

  final FocusNode focusNode = FocusNode();
  final TextEditingController editingController = TextEditingController();

  // -- Public state accessors (avoids protected-state access from outside) --
  int get type => state.type;
  int get oid => state.oid;

  /// Clears text and requests focus. Returns `true` if text was cleared,
  /// `false` if already empty (caller should navigate back).
  bool tryClear() {
    if (editingController.text.isNotEmpty) {
      editingController.clear();
      focusNode.requestFocus();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    focusNode.dispose();
    editingController.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final replySearchProvider = StateNotifierProvider.autoDispose.family<
    ReplySearchNotifier,
    ReplySearchState,
    ({int type, int oid})>((ref, params) {
  return ReplySearchNotifier(type: params.type, oid: params.oid);
});
