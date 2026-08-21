import 'package:skf/pages/common/common_controller_riverpod.dart';

abstract class LogController<R, T> extends CommonListControllerRiverpod<R, T> {
  LogController() {
    queryData();
  }

  String get title;

  T get header;

  List<(int, String)> getFlexAndText(T item);
}
