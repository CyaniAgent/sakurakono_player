import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// 页面过渡动画类型（设置页「页面过渡动画」）。
///
/// 枚举顺序与迁移前 GetX `Transition` 一致，保证已存储的偏好索引兼容；
/// `native` 为平台默认（迁移前默认值）。
enum AppPageTransition {
  fade,
  fadeIn,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  rightToLeftWithFade,
  leftToRightWithFade,
  zoom,
  topLevel,
  noTransition,
  cupertino,
  cupertinoDialog,
  size,
  circularReveal,
  native;

  static AppPageTransition fromIndex(int? index) {
    if (index == null || index < 0 || index >= values.length) {
      return native;
    }
    return values[index];
  }

  PageTransitionsBuilder get builder => switch (this) {
    fade ||
    fadeIn => const _FadePageTransitionsBuilder(),
    rightToLeft ||
    leftToRight ||
    cupertino ||
    cupertinoDialog => const CupertinoPageTransitionsBuilder(),
    upToDown ||
    downToUp => const _VerticalSlidePageTransitionsBuilder(),
    rightToLeftWithFade ||
    leftToRightWithFade ||
    size ||
    circularReveal => const _FadeSlidePageTransitionsBuilder(),
    zoom || topLevel => const ZoomPageTransitionsBuilder(),
    noTransition => const _NoTransitionPageTransitionsBuilder(),
    native => const ZoomPageTransitionsBuilder(),
  };
}

class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}

class _VerticalSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _VerticalSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

class _FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: const Offset(0.25, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

class _NoTransitionPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
