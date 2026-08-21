import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/pages/common/multi_select/base.dart';

abstract class MultiSelectController<
  R,
  T extends MultiSelectData
> extends CommonListController<R, T>
    with CommonMultiSelectMixin<T>, DeleteItemMixin {
  @override
  List<T>? get dataList => loadingState.value.data;

  @override
  void notifyStateChanged() => loadingState.refresh();
}
