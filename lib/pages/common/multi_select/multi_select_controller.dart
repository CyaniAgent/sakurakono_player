import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/pages/common/multi_select/base.dart';

abstract class MultiSelectController<
  R,
  T extends MultiSelectData
> = CommonListController<R, T>
    with CommonMultiSelectMixin<T>, DeleteItemMixin;
