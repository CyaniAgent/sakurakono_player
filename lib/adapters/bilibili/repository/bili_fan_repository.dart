import 'package:skf/adapters/bilibili/http/fan.dart';
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
                  'official_verify': e.officialVerify,
                })
            .toList(),
        'total': response.total,
      }));
    }
    return result as LoadingState<CoreFollowData>;
  }
}