import 'package:skf/adapters/bilibili/http/black.dart';

import 'package:skf/adapters/bilibili/models_new/blacklist/data.dart';
import 'package:skf/core/models/blacklist_data.dart';
import 'package:skf/core/models/blacklist_item.dart';
import 'package:skf/core/repository/black_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [BlackRepository] that delegates to [BlackHttp].
class BiliBlackRepository implements BlackRepository {
  // ---- conversion helper ----

  LoadingState<T> _toCore<T, A>(LoadingState<A> state, T Function(A) convert) {
    return switch (state) {
      Success<A>(:final response) => Success<T>(convert(response)),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
      Loading() => LoadingState<T>.loading(),
    };
  }

  @override
  Future<LoadingState<CoreBlackListData>> blackList({
    required int pn,
    int ps = 50,
  }) async {
    return _toCore(
      await BlackHttp.blackList(pn: pn, ps: ps),
      _toCoreBlackListData,
    );
  }

  static CoreBlackListData _toCoreBlackListData(BlackListData data) =>
      CoreBlackListData(
        list: data.list
            ?.map((e) => CoreBlackListItem.fromJson(<String, dynamic>{
                  'mid': e.mid,
                  'mtime': e.mtime,
                  'uname': e.uname,
                  'face': e.face,
                }))
            .toList(),
        total: data.total,
      );
}