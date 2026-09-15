import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skf/router/app_pages.dart';

/// 全局 GoRouter 实例，由 main.dart 构造并注入 MaterialApp.router。
/// Wave B: AppNavigator 的内部实现依赖此实例。
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'app-navigator');

  static GoRouter? _instance;

  static GoRouter get instance {
    if (_instance == null) {
      throw StateError(
        'AppRouter.instance not initialized. '
        'Call AppRouter.create() before runApp().',
      );
    }
    return _instance!;
  }

  /// 构造并缓存 GoRouter 实例（幂等：重复调用返回同一实例）。
  static GoRouter create({List<NavigatorObserver>? observers}) {
    final existing = _instance;
    if (existing != null) {
      return existing;
    }
    _instance = GoRouter(
      initialLocation: '/',
      routes: AppRoutes.routes,
      navigatorKey: navigatorKey,
      observers: observers ?? const [],
      // 适配器路由表不含根路径；入口统一重定向到主页壳（内部按
      // defaultHomeTabId 选初始 tab）。
      redirect: (context, state) {
        if (state.matchedLocation == '/') {
          return '/home';
        }
        return null;
      },
      errorPageBuilder: (context, state) {
        return MaterialPage(
          child: Scaffold(
            body: Center(
              child: Text('Route not found: ${state.matchedLocation}'),
            ),
          ),
        );
      },
    );
    return _instance!;
  }
}
