import 'package:skf/pages/main/view.dart' show MainApp;
import 'package:skf/core/adapter/adapter_registry.dart';
import 'package:get/get.dart';

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    GetPage(name: '/', page: () => const MainApp()),
    ...AdapterRegistry.active.routes,
  ];
}
