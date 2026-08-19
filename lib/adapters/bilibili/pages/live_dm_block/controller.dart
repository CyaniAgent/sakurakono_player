import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/live/live_dm_silent_type.dart'; // ignore: keep until CoreLiveDmSilentType exists
import 'package:skf/core/models/live_types.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

/// Immutable snapshot of the live danmaku block settings page state.
class LiveDmBlockState {
  const LiveDmBlockState({
    this.level = 0,
    this.rank = 0,
    this.verify = 0,
    this.isEnable = false,
    this.keywordList = const [],
    this.shieldUserList = const [],
  });

  final int level;
  final int rank;
  final int verify;
  final bool isEnable;
  final List<String> keywordList;
  final List<CoreShieldUserList> shieldUserList;

  LiveDmBlockState copyWith({
    int? level,
    int? rank,
    int? verify,
    bool? isEnable,
    List<String>? keywordList,
    List<CoreShieldUserList>? shieldUserList,
  }) =>
      LiveDmBlockState(
        level: level ?? this.level,
        rank: rank ?? this.rank,
        verify: verify ?? this.verify,
        isEnable: isEnable ?? this.isEnable,
        keywordList: keywordList ?? this.keywordList,
        shieldUserList: shieldUserList ?? this.shieldUserList,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Riverpod StateNotifier for the live danmaku block settings page.
///
/// The view owns the [TabController] (via [SingleTickerProviderStateMixin]).
class LiveDmBlockNotifier extends StateNotifier<LiveDmBlockState> {
  LiveDmBlockNotifier(this._ref, {required this.roomId})
      : super(const LiveDmBlockState()) {
    queryData();
  }

  final Ref _ref;
  final String roomId;

  LiveRepository get _repo => _ref.read(liveRepositoryProvider);

  // -- Data fetching --

  Future<void> queryData() async {
    final res = await _repo.getLiveInfoByUser(roomId);
    if (res case Success(:final response)) {
      final shieldRules = response?.shieldRules;
      final newLevel = shieldRules?.level ?? 0;
      final newRank = shieldRules?.rank ?? 0;
      final newVerify = shieldRules?.verify ?? 0;
      final newKeywordList = <String>[...state.keywordList];
      final newShieldUserList = <CoreShieldUserList>[
        ...state.shieldUserList,
      ];

      if (response?.keywordList case final kwList?) {
        newKeywordList.addAll(kwList);
      }
      if (response?.shieldUserList case final userList?) {
        newShieldUserList.addAll(userList);
      }

      state = state.copyWith(
        level: newLevel,
        rank: newRank,
        verify: newVerify,
        keywordList: newKeywordList,
        shieldUserList: newShieldUserList,
        isEnable: newLevel != 0 || newRank != 0 || newVerify != 0,
      );
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  // -- Slider live drag (no network, just UI feedback) --

  void updateLevel(int value) {
    state = state.copyWith(level: value);
  }

  // -- Silent rules --

  Future<bool> setSilent(
    LiveDmSilentType type,
    int level, {
    VoidCallback? onError,
  }) async {
    final res = await _repo.liveSetSilent(type: type.name, level: level);
    if (res.isSuccess) {
      switch (type) {
        case LiveDmSilentType.level:
          state = state.copyWith(level: level);
        case LiveDmSilentType.rank:
          state = state.copyWith(rank: level);
        case LiveDmSilentType.verify:
          state = state.copyWith(verify: level);
      }
      state = state.copyWith(
        isEnable: state.level != 0 || state.rank != 0 || state.verify != 0,
      );
      return true;
    } else {
      onError?.call();
      SmartDialog.showToast(res.toString());
      return false;
    }
  }

  Future<void> setEnable(bool enable) async {
    if (enable == state.isEnable) {
      return;
    }
    final futures = enable
        ? [
            setSilent(LiveDmSilentType.rank, 1),
            setSilent(LiveDmSilentType.verify, 1),
          ]
        : [
            for (final e in LiveDmSilentType.values) setSilent(e, 0),
          ];
    final res = await Future.wait(futures);
    if (enable) {
      if (res.any((e) => e)) {
        state = state.copyWith(isEnable: true);
      }
    } else {
      if (res.every((e) => e)) {
        state = state.copyWith(isEnable: false);
      }
    }
  }

  // -- Shield keyword / user mutations --

  Future<void> addShieldKeyword(bool isKeyword, String value) async {
    if (isKeyword) {
      final res = await _repo.addShieldKeyword(keyword: value);
      if (res.isSuccess) {
        state = state.copyWith(
          keywordList: [value, ...state.keywordList],
        );
      } else {
        SmartDialog.showToast(res.toString());
      }
    } else {
      final res = await _repo.liveShieldUser(
        uid: int.tryParse(value) ?? 0,
        roomid: int.parse(roomId),
        type: 1,
      );
      if (res case Success(:final response)) {
        state = state.copyWith(
          shieldUserList: [response, ...state.shieldUserList],
        );
      } else {
        SmartDialog.showToast(res.toString());
      }
    }
  }

  Future<void> onRemove(int index, Object item) async {
    assert(item is CoreShieldUserList || item is String);
    if (item is CoreShieldUserList) {
      final res = await _repo.liveShieldUser(
        uid: item.uid!,
        roomid: int.parse(roomId),
        type: 0,
      );
      if (res.isSuccess) {
        final newList = [...state.shieldUserList]..removeAt(index);
        state = state.copyWith(shieldUserList: newList);
      } else {
        SmartDialog.showToast(res.toString());
      }
    } else {
      final res = await _repo.delShieldKeyword(keyword: item as String);
      if (res.isSuccess) {
        final newList = [...state.keywordList]..removeAt(index);
        state = state.copyWith(keywordList: newList);
      } else {
        SmartDialog.showToast(res.toString());
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Family provider keyed by room ID.
///
/// Usage:
/// ```dart
/// final state = ref.watch(liveDmBlockProvider(roomId));
/// ref.read(liveDmBlockProvider(roomId).notifier).setEnable(true);
/// ```
final liveDmBlockProvider = StateNotifierProvider.family<
    LiveDmBlockNotifier, LiveDmBlockState, String>(
  (ref, roomId) => LiveDmBlockNotifier(ref, roomId: roomId),
);
