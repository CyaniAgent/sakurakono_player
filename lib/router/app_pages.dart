import 'package:go_router/go_router.dart';
import 'package:skf/core/adapter/adapter_registry.dart';

/// 路由表：所有路由由当前激活的 adapter 提供。
class AppRoutes {
  static List<GoRoute> get routes => [
    // 根路由——应用主页
    ...AdapterRegistry.active.routes,
  ];
}
