import 'package:skf/core/models/ui/multi_select_controller.dart';
import 'package:skf/core/models/ui/multi_select_data.dart';

export 'package:skf/core/models/ui/multi_select_data.dart';

abstract interface class MultiSelectBase<T extends MultiSelectData>
    implements CoreMultiSelectController {
  @override
  bool get enableMultiSelect;

  @override
  int get checkedCount;

  void onSelect(T item);
  @override
  void handleSelect({bool checked = false, bool disableSelect = true});
  @override
  void onRemove();
}

mixin BaseMultiSelectMixin<T extends MultiSelectData>
    implements MultiSelectBase<T> {
  int rxCount = 0;
  @override
  int get checkedCount => rxCount;

  @override
  bool enableMultiSelect = false;

  void notifyStateChanged();
  List<T> get list;

  Iterable<T> get allChecked => list.where((v) => v.checked);

  @override
  void handleSelect({bool checked = false, bool disableSelect = true}) {
    for (final item in list) {
      item.checked = checked;
    }
    notifyStateChanged();
    rxCount = checked ? list.length : 0;
    if (disableSelect && !checked) {
      enableMultiSelect = false;
    }
  }

  @override
  void onSelect(T item) {
    item.checked = !item.checked;
    if (item.checked) {
      rxCount++;
    } else {
      rxCount--;
    }
    notifyStateChanged();
    if (checkedCount == 0) {
      enableMultiSelect = false;
    }
  }
}

mixin CommonMultiSelectMixin<T extends MultiSelectData>
    implements MultiSelectBase<T> {
  @override
  bool enableMultiSelect = false;
  bool? allSelected;

  List<T>? get dataList;
  void notifyStateChanged();
  int rxCount = 0;

  @override
  int get checkedCount => rxCount;

  Iterable<T> get allChecked =>
      dataList!.where((v) => v.checked);

  @override
  void onSelect(T item) {
    List<T> list = dataList!;
    item.checked = !item.checked;
    if (item.checked) {
      rxCount++;
    } else {
      rxCount--;
    }
    notifyStateChanged();
    if (checkedCount == 0) {
      enableMultiSelect = false;
    } else {
      allSelected = checkedCount == list.length;
    }
  }

  @override
  void handleSelect({bool checked = false, bool disableSelect = true}) {
    final response = dataList;
    if (response != null && response.isNotEmpty) {
      for (final item in response) {
        item.checked = checked;
      }
      notifyStateChanged();
      rxCount = checked ? response.length : 0;
    }
    if (disableSelect && !checked) {
      enableMultiSelect = false;
    }
  }
}

mixin DeleteItemMixin<T extends MultiSelectData>
    on CommonMultiSelectMixin<T> {
  bool get isEnd;
  Future<void> onReload();
  Future<void> afterDelete(Set<T> removeList) async {
    final list = dataList!;
    if (removeList.length == list.length) {
      list.clear();
    } else if (removeList.length == 1) {
      list.remove(removeList.first);
    } else {
      list.removeWhere(removeList.contains);
    }
    if (list.isNotEmpty || isEnd) {
      notifyStateChanged();
    } else {
      onReload();
    }
    if (enableMultiSelect) {
      rxCount = 0;
      enableMultiSelect = false;
    }
  }
}

// abstract class SetMultiSelectController<R, T, I>
//     extends CommonListController<R, T>
//     with MultiSelectMixin<T>, SetCommonMultiSelectMixin<T, I> {}

// mixin SetCommonMultiSelectMixin<T, R> on MultiSelectMixin<T> {
//   Rx<LoadingState<List<T>?>> get loadingState;
//   RxSet<R> get selected;

//   @override
//   int get checkedCount => selected.length;

//   R getId(T item);

//   @override
//   void onSelect(T item, [bool disableSelect = true]) {
//     final id = getId(item);
//     if (selected.contains(id)) {
//       selected.remove(id);
//     } else {
//       selected.add(id);
//     }
//     loadingState.refresh();
//     if (disableSelect) {
//       if (checkedCount == 0) {
//         enableMultiSelect.value = false;
//       }
//     } else {
//       allSelected.value = checkedCount == loadingState.value.data!.length;
//     }
//   }

//   @override
//   void handleSelect([bool checked = false, bool disableSelect = true]) {
//     if (loadingState.value.isSuccess) {
//       final list = loadingState.value.data;
//       if (list != null && list.isNotEmpty) {
//         if (checked) {
//           selected.addAll(list!.map(getId));
//         } else {
//           selected.clear();
//         }
//         loadingState.refresh();
//       }
//     }
//     if (disableSelect && !checked) {
//       enableMultiSelect.value = false;
//     }
//   }
// }
