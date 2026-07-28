import 'package:get/get.dart';

/// Minimal interface for multi-select functionality used by [MultiSelectAppBarWidget].
///
/// This is a subset of [MultiSelectBase] that only exposes the members
/// needed by the app bar widget, allowing it to be adapter-independent.
abstract interface class CoreMultiSelectController {
  RxBool get enableMultiSelect;

  int get checkedCount;

  void handleSelect({bool checked = false, bool disableSelect = true});

  void onRemove();
}