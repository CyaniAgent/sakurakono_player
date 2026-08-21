import 'package:skf/adapters/bilibili/grpc/bilibili/app/interfaces/v1.pb.dart'
    show SearchArchiveReply;
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/space_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/member/search_type.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/pages/member_search/controller.dart';
import 'package:fixnum/fixnum.dart' show Int64;
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

class MemberSearchChildController extends CommonListControllerRiverpod {
  MemberSearchChildController(this.controller, this.searchType);

  final MemberSearchController controller;
  final MemberSearchType searchType;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  // archive
  late final _ps = Int64(20);
  late final _midInt64 = Int64(int.parse(controller.mid));

  // dynamic
  String? offset;

  @override
  void checkIsEnd(int length) {
    final count = controller.counts[searchType.index];
    if (count != -1 && length >= count) {
      isEnd = true;
    }
  }

  @override
  List? getDataList(response) {
    switch (searchType) {
      case MemberSearchType.archive:
        SearchArchiveReply data = response;
        controller.counts[searchType.index] = data.total.toInt();
        controller.notifyListeners();
        return data.archives;
      case MemberSearchType.dynamic:
        CoreDynamicsDataModel data = response;
        offset = data.offset;
        if (data.hasMore == false) {
          isEnd = true;
        }
        controller.counts[searchType.index] = data.total ?? 0;
        controller.notifyListeners();
        return data.items;
    }
  }

  @override
  Future<void> onRefresh() {
    offset = null;
    return super.onRefresh();
  }

  @override
  Future<LoadingState> customGetData() {
    return switch (searchType) {
      MemberSearchType.archive => (_ref?.read(spaceRepositoryProvider) ?? Get.find<SpaceRepository>()).searchArchive(
        mid: _midInt64,
        pn: page,
        ps: _ps,
        keyword: controller.editingController.text,
      ),
      MemberSearchType.dynamic => (_ref?.read(memberRepositoryProvider) ?? Get.find<MemberRepository>()).dynSearch(
        mid: int.parse(controller.mid),
        pn: page,
        offset: offset ?? '',
        keyword: controller.editingController.text,
      ),
    };
  }
}
