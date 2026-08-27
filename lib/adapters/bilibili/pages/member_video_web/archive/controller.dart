import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/base/controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:get/get.dart';

class MemberVideoWebCtr
    extends
        BaseVideoWebCtr<
          CoreSearchArchiveData,
          CoreVListItemModel,
          CoreArchiveOrderTypeWeb
        > {
  @override
  final Rx<CoreArchiveOrderTypeWeb> order = Rx(CoreArchiveOrderTypeWeb.pubdate);

  int tid = 0;
  String? specialType;
  List<CoreListTag>? tags;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  @override
  List<CoreVListItemModel>? getDataList(CoreSearchArchiveData response) {
    return response.list?.vlist;
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<CoreSearchArchiveData> response,
  ) {
    if (isRefresh) {
      final data = response.response;
      if (data.corePage?.count case final count?) {
        this.count = count;
        totalPage = (count / ps).ceil();
      }
      final tags = data.list?.tags;
      if (tags?.isNotEmpty ?? false) {
        this.tags = tags!
          ..insert(0, CoreListTag(tid: 0, name: '全部类型'));
      }
    }
    return false;
  }

  @override
  Future<LoadingState<CoreSearchArchiveData>> customGetData() async {
    final result = await (_ref!.read(memberRepositoryProvider)).searchArchive(
      mid: mid,
      ps: ps,
      pn: page,
      order: order.value,
      tid: tid,
      specialType: specialType,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
