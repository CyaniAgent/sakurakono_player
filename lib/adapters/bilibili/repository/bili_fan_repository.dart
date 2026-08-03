import 'package:skf/adapters/bilibili/http/fan.dart';
import 'package:skf/core/models/fan_model.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/repository/fan_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [FanRepository] that delegates to [FanHttp].
class BiliFanRepository implements FanRepository {
  @override
  Future<LoadingState<CoreFollowData>> fans({
    int? vmid,
    int? pn,
    int ps = 20,
    String? orderType,
  }) async {
    final result = await FanHttp.fans(
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
  Future<LoadingState<CoreActiveFollower?>> activeFollower() async {
    // Bilibili API does not have a dedicated active follower endpoint.
    return const Error('not_implemented');
  }
}