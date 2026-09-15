import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/tab2.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

class MemberContributeState {
  const MemberContributeState({
    this.items,
    this.tabs,
    this.currentIndex = 0,
  });

  final List<dynamic>? items;
  final List<Tab>? tabs;
  final int currentIndex;

  MemberContributeState copyWith({
    List<dynamic>? items,
    List<Tab>? tabs,
    int? currentIndex,
  }) {
    return MemberContributeState(
      items: items ?? this.items,
      tabs: tabs ?? this.tabs,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class MemberContributeNotifier extends StateNotifier<MemberContributeState> {
  MemberContributeNotifier({
    required this.heroTag,
    required this.initialIndex,
  }) : super(
          MemberContributeState(currentIndex: max(0, initialIndex)),
        );

  final String? heroTag;
  final int initialIndex;

  // Static bridge for non-widget access (member_host.dart, member_home).
  static final Map<String?, MemberContributeState> _states = {};

  static MemberContributeState? getState(String? heroTag) =>
      _states[heroTag];

  static bool isRegistered(String? heroTag) =>
      _states.containsKey(heroTag);

  void _syncState() {
    if (heroTag != null) _states[heroTag] = state;
  }

  /// Populate state from MemberController data.
  /// Called by the view after reading MemberController.
  void initData({
    required List<dynamic>? contributeItems,
    required bool hasSeasonOrSeries,
  }) {
    if (contributeItems == null || contributeItems.isEmpty) return;

    // CoreSpaceTab2.items 是原始 Map，统一归一成 SpaceTab2Item（build 侧强转依赖此类型）
    final items = contributeItems
        .map(
          (e) => e is SpaceTab2Item
              ? e
              : SpaceTab2Item.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
    List<Tab>? tabs;

    if (items.length > 1) {
      if (hasSeasonOrSeries) {
        items.add(const SpaceTab2Item(title: '全部合集/列表', param: 'ugcSeason'));
      }
      tabs = items.map((item) => Tab(text: item.title)).toList();
    }

    state = MemberContributeState(
      items: items,
      tabs: tabs,
      currentIndex: max(0, initialIndex),
    );
    _syncState();
  }

  void updateIndex(int index) {
    state = state.copyWith(currentIndex: index);
    _syncState();
  }

  @override
  void dispose() {
    if (heroTag != null) _states.remove(heroTag);
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final memberContributeProvider = StateNotifierProvider.autoDispose
    .family<MemberContributeNotifier, MemberContributeState, String?>(
  (ref, heroTag) => MemberContributeNotifier(
    heroTag: heroTag,
    initialIndex: 0,
  ),
);
