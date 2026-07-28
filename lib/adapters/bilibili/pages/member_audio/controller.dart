import 'package:skf/adapters/bilibili/grpc/bilibili/app/listener/v1.pbenum.dart'
    show PlaylistSource;
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/pages/audio/view.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';

class MemberAudioController
    extends CommonListController<CoreSpaceAudioData, CoreSpaceAudioItem> {
  MemberAudioController(this.mid);

  final int mid;
  int? totalSize;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  void checkIsEnd(int length) {
    if (totalSize != null && length >= totalSize!) {
      isEnd = true;
    }
  }

  @override
  List<CoreSpaceAudioItem>? getDataList(CoreSpaceAudioData response) {
    totalSize = response.totalSize;
    return response.items;
  }

  @override
  Future<LoadingState<CoreSpaceAudioData>> customGetData() async {
    final result = await Get.find<MemberRepository>().spaceAudio(
      page: page,
      mid: mid,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void toViewPlayAll() {
    final item = loadingState.value.data!.first;
    AudioPage.toAudioPage(
      itemType: 3,
      id: item.uid!,
      oid: item.id!,
      from: PlaylistSource.MEM_SPACE,
    );
  }
}
