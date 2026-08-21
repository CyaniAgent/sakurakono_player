import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/pages/common/multi_select/base.dart';

abstract class MultiSelectController<
  R,
  T extends MultiSelectData
> extends CommonListControllerRiverpod<R, T>
    with CommonMultiSelectMixin<T>, DeleteItemMixin {
  @override
  List<T>? get dataList => loadingState.data;

  @override
  void notifyStateChanged() => notifyListeners();
}
