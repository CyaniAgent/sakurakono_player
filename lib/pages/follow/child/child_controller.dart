
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/follow/follow_models.dart' show FollowOrderType;
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/pages/follow/controller.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class FollowChildController
    extends CommonListControllerRiverpod<CoreFollowData, CoreFollowItemModel> {
  FollowChildController(this._followState, this._notifier, this.mid, this.tagid) {
    queryData();
    if (loadSameFollow) {
      _loadSameFollow();
    }
  }
  final FollowState? _followState;
  final FollowControllerNotifier? _notifier;
  final int? tagid;
  final int mid;
  int? total;

  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { _ref = ref; }

  late final loadSameFollow = _followState?.isOwner == false;
  LoadingState<List<CoreFollowItemModel>?> sameState =
      LoadingState<List<CoreFollowItemModel>?>.loading();

  FollowOrderType orderType = FollowOrderType.values[Pref.followOrderType];


  @override
  List<CoreFollowItemModel>? getDataList(CoreFollowData response) {
    total = response.total;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (total != null && length >= total!) {
      isEnd = true;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreFollowData> response) {
    if (_followState != null && _notifier != null) {
      try {
        if (_followState.isOwner &&
            tagid == null &&
            isRefresh &&
            _followState.hasLoadedTags) {
          final total = response.response.total;
          if (total != null) {
            _notifier.updateTabCount(total);
          }
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Future<LoadingState<CoreFollowData>> customGetData() async {
    if (tagid != null) {
      final biliResult = await (_ref!.read(memberRepositoryProvider)).followUpGroup(
        mid: mid,
        tagid: tagid,
        pn: page,
      );
      return switch (biliResult) {
        Success<CoreFollowData>(:final response) => Success<CoreFollowData>(response),
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
        _ => LoadingState.loading(),
      };
    }

    return (_ref!.read(followRepositoryProvider)).followings(
      vmid: mid,
      pn: page,
      orderType: orderType.type,
    );
  }

  Future<void> _loadSameFollow() async {
    final res = await (_ref!.read(userRepositoryProvider)).sameFollowing(mid: mid);
    if (res case Success(:final response)) {
      sameState = Success(response.list);
    }
  }
}
