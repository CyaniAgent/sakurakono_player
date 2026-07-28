import 'package:skf/adapters/bilibili/pages/main/view.dart' show MainApp;
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:get/get.dart';

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    GetPage(name: '/', page: () => const MainApp()),
    ...BiliBridge.registerRoutes(),
  ];
}
