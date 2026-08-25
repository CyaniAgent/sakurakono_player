import 'package:skf/common/style.dart';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bar-state contract consumed by [CommonPageState].
///
/// Implemented by the active adapter's main scaffold controller so the
/// generic page layer stays free of adapter imports.
abstract interface class MainBarState {
  double? get barOffset;
  set barOffset(double? value);
  bool? get showBottomBar;
  set showBottomBar(bool? value);
  bool get useBottomNav;
}

/// Top-bar visibility contract implemented by the adapter's home controller.
abstract interface class HomeBarState {
  bool? get showTopBar;
  set showTopBar(bool? value);
}

abstract class CommonPageState<T extends StatefulWidget> extends State<T> {
  MainBarState? _mainBarState;
  HomeBarState? _homeBarState;

  // ignore: unused_field
  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during state initialization.
  void attachRef(Ref ref) { _ref = ref; }

  bool get needsCorrection => false;

  @override
  void initState() {
    super.initState();
    _mainBarState = appRead(mainBarStateProvider);
    try {
      _homeBarState = appRead(homeBarStateProvider);
    } catch (_) {}
  }

  Widget onBuild(Widget child) {
    if (_mainBarState?.barOffset != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: onNotificationType2,
        child: child,
      );
    }
    if (_homeBarState?.showTopBar != null || _mainBarState?.showBottomBar != null) {
      return NotificationListener<UserScrollNotification>(
        onNotification: onNotificationType1,
        child: child,
      );
    }
    return child;
  }

  bool onNotificationType1(UserScrollNotification notification) {
    if (!_mainBarState!.useBottomNav) return false;
    if (notification.metrics.axis == .horizontal) return false;
    switch (notification.direction) {
      case .forward:
        _homeBarState?.showTopBar = true;
        _mainBarState?.showBottomBar = true;
      case .reverse:
        _homeBarState?.showTopBar = false;
        _mainBarState?.showBottomBar = false;
      case _:
    }
    return false;
  }

  void _updateOffset(double scrollDelta) {
    final current = _mainBarState!.barOffset ?? 0.0;
    _mainBarState!.barOffset = clampDouble(
      current + scrollDelta,
      0.0,
      Style.topBarHeight,
    );
  }

  bool onNotificationType2(ScrollNotification notification) {
    if (!_mainBarState!.useBottomNav) return false;

    final metrics = notification.metrics;
    if (metrics.axis == .horizontal) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails == null) return false;
      final pixel = metrics.pixels;
      final scrollDelta = notification.scrollDelta ?? 0;
      if (pixel < 0.0 && scrollDelta > 0) return false;
      if (needsCorrection) {
        final value = _mainBarState!.barOffset ?? 0.0;
        final newValue = clampDouble(
          value + scrollDelta,
          0.0,
          Style.topBarHeight,
        );
        final offset = value - newValue;
        if (offset != 0) {
          _mainBarState!.barOffset = newValue;
          if (pixel < 0.0 && scrollDelta < 0.0 && value > 0.0) {
            return false;
          }
          Scrollable.of(notification.context!).position.correctBy(offset);
        }
      } else {
        _updateOffset(scrollDelta);
      }
      return false;
    }

    if (notification is OverscrollNotification) {
      _updateOffset(notification.overscroll);
      return false;
    }

    return false;
  }

  @override
  void dispose() {
    _mainBarState = null;
    _homeBarState = null;
    super.dispose();
  }
}
