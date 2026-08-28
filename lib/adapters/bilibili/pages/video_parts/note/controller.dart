import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class NoteListPageCtr
    extends CommonListControllerRiverpod<CoreVideoNoteData, Map<String, dynamic>> {
  void attachRef(Ref ref) {}
  NoteListPageCtr({required this.oid}) {
    queryData();
  }
  final int oid;

  int _count = -1;
  int get count => _count;
  set count(int value) {
    _count = value;
    notifyListeners();
  }


  @override
  List<Map<String, dynamic>>? getDataList(CoreVideoNoteData response) {
    count = response.page?['total'] as int? ?? -1;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    final count = this.count;
    if (count != -1 && length >= count) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<CoreVideoNoteData>> customGetData() async {
    final result = await (appRead(videoRepositoryProvider)).getVideoNoteList(
      oid: oid.toString(),
      page: page,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
