import 'package:skf/adapters/bilibili/http/follow.dart';
import 'package:skf/core/models/follow_data.dart';
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
  Future<LoadingState<void>> sortFollowTag({required String tagids}) {
    return FollowHttp.sortFollowTag(tagids: tagids);
  }
}