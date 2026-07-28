import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/adapters/bilibili/pages/common/multi_select/multi_select_controller.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class FavNoteController
    extends MultiSelectController<List<CoreFavNoteItemModel>?, CoreFavNoteItemModel> {
  FavNoteController(this.isPublish);

  final bool isPublish;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  final RxBool allSelected = false.obs;

  @override
  void handleSelect({bool checked = false, bool disableSelect = true}) {
    allSelected.value = checked;
    super.handleSelect(checked: checked, disableSelect: disableSelect);
  }

  @override
  Future<LoadingState<List<CoreFavNoteItemModel>?>> customGetData() async {
    final result = isPublish
        ? await Get.find<FavRepository>().userNoteList(page: page)
        : await Get.find<FavRepository>().noteList(page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<void> onRemove() async {
    final removeList = allChecked.toSet();
    final res = await Get.find<FavRepository>().delNote(
      isPublish: isPublish,
      noteIds: removeList
          .map((item) => isPublish ? item.cvid : item.noteId)
          .join(','),
    );
    if (res.isSuccess) {
      afterDelete(removeList);
      SmartDialog.showToast('删除成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  void onDisable() {
    if (checkedCount != 0) {
      handleSelect();
    }
    enableMultiSelect.value = false;
  }
}
