import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skf/router/app_router.dart';

/// 导航门面：所有导航调用统一经此入口，内部由 go_router 驱动。
/// 调用点禁止直连 GetX 导航 API 或 GoRouter——所有路由操作通过本类。
abstract final class AppNavigator {
  /// 全局导航 key（MaterialApp.router 的 navigatorKey）。
  static GlobalKey<NavigatorState> get navigatorKey => AppRouter.navigatorKey;

  /// 全局根 context（navigatorKey.currentContext，应用挂载后可用）。
  static BuildContext? get context => navigatorKey.currentContext;

  /// 当前路由路径（如 '/videoV'）。等效 `AppNavigator.currentRoute`。
  static String get currentRoute {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return '/';
    return GoRouterState.of(ctx).uri.path;
  }

  /// 上一路由名（go_router 无直接 API，由 [_PreviousRouteObserver] 记录）。
  static String get previousRoute => _previousRoute;

  static String _previousRoute = '';

  /// 记录上一路由的 observer，注册到 AppRouter.create(observers:)。
  static final NavigatorObserver observer = _PreviousRouteObserver();

  /// 当前路由 query 参数（无 context 版本，controller 层用）。
  static Map<String, String?> get parameters =>
      AppRouter.instance.state.uri.queryParameters;

  /// 读取当前路由参数（extra），controller 层用（无 context）。
  static dynamic get arguments {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return null;
    return ModalRoute.of(ctx)?.settings.arguments;
  }

  /// 读取路由参数（go_router 的 extra）。
  static dynamic argsOf(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments;
  }

  /// 读取当前路由 query 参数（如 '/member?mid=123' 的 mid）。
  static Map<String, String?> parametersOf(BuildContext context) {
    final state = GoRouterState.of(context);
    return state.uri.queryParameters;
  }

  /// 推入命名路由。等效 `Get.toNamed`。
  static Future<T?>? toNamed<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    bool preventDuplicates = true,
  }) {
    final router = AppRouter.instance;
    final uri = buildUri(page, parameters);
    if (preventDuplicates) {
      final current = router.state.matchedLocation;
      if (isDuplicate(uri, current)) return null;
    }
    return router.pushNamed<T>(uri.toString(), extra: arguments);
  }

  /// 推入命名路由并替换当前页。等效 `Get.offNamed`。
  static Future<T?>? replaceNamed<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    bool preventDuplicates = true,
  }) {
    final router = AppRouter.instance;
    final uri = buildUri(page, parameters);
    if (preventDuplicates) {
      final current = router.state.matchedLocation;
      if (isDuplicate(uri, current)) return null;
    }
    return router.pushReplacementNamed<T>(uri.toString(), extra: arguments);
  }

  /// 推入命名路由并清空栈。等效 `Get.offAllNamed`。
  static Future<T?>? offAllNamed<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    RoutePredicate? predicate,
  }) {
    final uri = buildUri(page, parameters);
    AppRouter.instance.go(uri.toString(), extra: arguments);
    return Future<T?>.value(null);
  }

  /// 允许重复入栈的命名路由推送。等效 `PageUtils.toDupNamed`（preventDuplicates: false）。
  static Future<T?>? toDupNamed<T>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    bool off = false,
  }) {
    if (off) {
      final uri = buildUri(page, parameters);
      AppRouter.instance.go(uri.toString(), extra: arguments);
      return Future<T?>.value(null);
    }
    return toNamed<T>(
      page,
      arguments: arguments,
      parameters: parameters,
      preventDuplicates: false,
    );
  }

  /// 弹出当前页（根路由 no-op）。等效 `AppNavigator.back`。
  static void back<T>({T? result, bool canPop = true}) {
    navigatorKey.currentState?.maybePop<T>(result);
  }

  /// 弹出直到根路由。等效 `Get.key.currentState!.popUntil(route.isFirst)`。
  static void popUntilFirst() {
    AppRouter.instance.go('/');
  }

  /// 连续弹出直到 [predicate] 为真。等效 `Get.until`。
  static void until(RoutePredicate predicate) {
    navigatorKey.currentState?.popUntil(predicate);
  }

  /// 直推 widget 页。等效 `Get.to`。
  static Future<T?>? to<T>(
    dynamic page, {
    dynamic arguments,
    bool preventDuplicates = true,
    String? routeName,
  }) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;
    return navigator.push<T>(
      MaterialPageRoute(
        builder: (_) => page as Widget,
    settings: RouteSettings(name: routeName, arguments: arguments),
      ),
    );
  }

  /// 直推 Route 对象（如 HeroDialogRoute）。等效 `AppNavigator.push`。
  static Future<T?>? push<T>(Route<T> route) {
    return navigatorKey.currentState?.push<T>(route);
  }

  /// 判断目标 URI 与当前路由是否重复（含 query 比较）。
  @visibleForTesting
  static bool isDuplicate(Uri uri, String? current) => current == uri.toString();

  /// 构建 URI，合并路径和查询参数。
  @visibleForTesting
  static Uri buildUri(String path, Map<String, String>? parameters) {
    if (parameters == null || parameters.isEmpty) {
      return Uri.parse(path);
    }
    final base = Uri.parse(path);
    return base.replace(
      queryParameters: {
        ...base.queryParameters,
        ...parameters,
      },
    );
  }
}

/// 记录上一路由的 NavigatorObserver。
class _PreviousRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _track(oldRoute);
  }

  void _track(Route<dynamic>? previousRoute) {
    if (previousRoute == null) return;
    AppNavigator._previousRoute = previousRoute.settings.name ?? '';
  }
}
