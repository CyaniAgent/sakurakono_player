import 'package:skf/adapters/bilibili/http/follow.dart';
import 'package:skf/adapters/bilibili/http/member.dart';
import 'package:skf/adapters/bilibili/http/user.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_status.dart';
import 'package:skf/core/repository/follow_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [FollowRepository] that delegates to [FollowHttp].
class BiliFollowRepository implements FollowRepository {
  @override
  Future<LoadingState<CoreFollowData>> followings({
    int? vmid,
    int? pn,
    int ps = 20,
    String orderType = '',
  }) async {
    final result = await FollowHttp.followings(
      vmid: vmid,
      pn: pn,
      ps: ps,
      orderType: orderType,
    );
    if (result case Success(:final response)) {
      return Success(CoreFollowData.fromJson(<String, dynamic>{
        'list': response.list
            ?.map((e) => <String, dynamic>{
                  'mid': e.mid,
                  'uname': e.uname,
                  'face': e.face,
                  'attribute': e.attribute,
                  'sign': e.sign,
                  'official_verify': e.officialVerify?.toJson(),
                })
            .toList(),
        'total': response.total,
      }));
    }
    return result as LoadingState<CoreFollowData>;
  }

  @override
  Future<LoadingState<void>> toggleFollow({
    required int fid,
    int? type,
  }) {
    // type: 1 = follow, 2 = unfollow, null = follow by default
    return MemberHttp.specialAction(fid: fid, isAdd: type != 2);
  }

  @override
  Future<LoadingState<CoreFollowStatus>> followStatus({
    required int fid,
  }) async {
    final result = await UserHttp.userRelation(fid);
    if (result case Success(:final response)) {
      return Success(CoreFollowStatus(status: response.attribute ?? 0));
    }
    return result as LoadingState<CoreFollowStatus>;
  }

  @override
  Future<LoadingState<void>> sortFollowTag({required String tagids}) {
    return FollowHttp.sortFollowTag(tagids: tagids);
  }
}