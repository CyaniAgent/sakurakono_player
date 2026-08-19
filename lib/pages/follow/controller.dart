/// Riverpod-based follow-tag management state + notifier + provider.
///
/// Replaces the former GetX [FollowController].
/// TabController lifecycle is managed by the view (ConsumerStatefulWidget
/// provides the TickerProvider).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

/// Immutable snapshot of the follow-tag management page state.
class FollowState {
  const FollowState({
    this.mid = 0,
    this.name,
    this.isOwner = false,
    this.tabs = const [],
    this.currentTabIndex = 0,
    this.isTagsLoading = false,
    this.tagsError,
  });

  /// Target user ID.
  final int mid;

  /// Display name (null until fetched for non-owner).
  final String? name;

  /// Whether the current user owns this follow list.
  final bool isOwner;

  /// Ordered list of follow tags (first entry is always "全部关注").
  final List<CoreMemberTagItemModel> tabs;

  /// Currently selected tab index (view-managed).
  final int currentTabIndex;

  /// Whether follow tags are being loaded.
  final bool isTagsLoading;

  /// Error message from the last failed follow-tags query, if any.
  final String? tagsError;

  /// Whether tags have been successfully loaded at least once.
  bool get hasLoadedTags => tabs.isNotEmpty;

  FollowState copyWith({
    int? mid,
    String? name,
    bool clearName = false,
    bool? isOwner,
    List<CoreMemberTagItemModel>? tabs,
    int? currentTabIndex,
    bool? isTagsLoading,
    String? tagsError,
    bool clearError = false,
  }) =>
      FollowState(
        mid: mid ?? this.mid,
        name: clearName ? null : (name ?? this.name),
        isOwner: isOwner ?? this.isOwner,
        tabs: tabs ?? this.tabs,
        currentTabIndex: currentTabIndex ?? this.currentTabIndex,
        isTagsLoading: isTagsLoading ?? this.isTagsLoading,
        tagsError: clearError ? null : (tagsError ?? this.tagsError),
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Riverpod StateNotifier that manages follow-tag state.
///
/// Reads [MemberRepository] from a Riverpod provider for data fetching.
/// The view is responsible for creating and disposing the [TabController].
class FollowControllerNotifier extends StateNotifier<FollowState> {
  FollowControllerNotifier(this._ref) : super(const FollowState()) {
    _init();
  }

  final Ref _ref;

  MemberRepository get _memberRepo => _ref.read(memberRepositoryProvider);

  // -- Lifecycle --

  void _init() {
    final args = AppNavigator.arguments;
    final ownerMid = _ref.read(accountProvider).userId ?? 0;
    final int? mid = args?['mid'] as int?;
    final resolvedMid = mid ?? ownerMid;
    final isOwner = ownerMid == resolvedMid;

    state = state.copyWith(
      mid: resolvedMid,
      isOwner: isOwner,
    );

    if (isOwner) {
      queryFollowUpTags();
    } else {
      final String? name = args?['name'] as String?;
      if (name != null) {
        state = state.copyWith(name: name);
      } else {
        _queryUserName();
      }
    }
  }

  // -- Data fetching --

  Future<void> _queryUserName() async {
    final res = await _memberRepo.memberCardInfo(mid: state.mid);
    final fetchedName = res.dataOrNull?.card?.name;
    if (fetchedName != null) {
      state = state.copyWith(name: fetchedName);
    }
  }

  Future<void> queryFollowUpTags() async {
    state = state.copyWith(isTagsLoading: true, clearError: true);

    final res = await _memberRepo.followUpTags();
    if (res case Success(:final response)) {
      final tags = [
        CoreMemberTagItemModel(name: '全部关注'),
        ...response,
      ];
      state = state.copyWith(
        tabs: tags,
        isTagsLoading: false,
      );
    } else {
      state = state.copyWith(
        isTagsLoading: false,
        tagsError: switch (res) {
          Error(:final errMsg) => errMsg ?? '加载失败',
          _ => '加载失败',
        },
      );
    }
  }

  // -- Tag mutations --

  void onCreateFavTag(({int tagid, String tagName}) res) {
    if (state.hasLoadedTags) {
      final updatedTabs = [
        ...state.tabs,
        CoreMemberTagItemModel.fromCreate(res),
      ];
      state = state.copyWith(tabs: updatedTabs);
    } else {
      queryFollowUpTags();
    }
  }

  Future<void> onUpdateTag(CoreMemberTagItemModel item, String tagName) async {
    final res = await _memberRepo.updateFollowTag(item.tagid!, tagName);
    if (res.isSuccess) {
      item.name = tagName;
      // Force rebuild by updating the tabs list reference.
      state = state.copyWith(tabs: [...state.tabs]);
      SmartDialog.showToast('修改成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  Future<void> onDelTag(int index, int tagid) async {
    final res = await _memberRepo.delFollowTag(tagid);
    if (res.isSuccess) {
      final updatedTabs = [...state.tabs]..removeAt(index);
      state = state.copyWith(tabs: updatedTabs);
      SmartDialog.showToast('删除成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  // -- Tab index --

  void setTabIndex(int index) {
    state = state.copyWith(currentTabIndex: index);
  }

  // -- Tab count update (called from child controller) --

  void updateTabCount(int total) {
    final currentTabs = state.tabs;
    if (currentTabs.isEmpty) return;
    currentTabs[0].count = total;
    state = state.copyWith(tabs: [...currentTabs]);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provider for the follow controller.
///
/// Usage:
/// ```dart
/// final followState = ref.watch(followControllerProvider);
/// ref.read(followControllerProvider.notifier).onCreateFavTag(res);
/// ```
final followControllerProvider =
    StateNotifierProvider.autoDispose<FollowControllerNotifier, FollowState>(
  FollowControllerNotifier.new,
);
