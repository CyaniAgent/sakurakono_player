import 'package:skf/common/style.dart';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bar-state contract consumed by [CommonPageState].
///
/// Implemented by the active adapter's main scaffold controller so the
/// generic page layer stays free of adapter imports.
abstract interface class MainBarState {
  RxDouble? get barOffset;
  RxBool? get showBottomBar;
  bool get useBottomNav;
}

/// Top-bar visibility contract implemented by the adapter's home controller.
abstract interface class HomeBarState {
  RxBool? get showTopBar;
}

abstract class CommonPageState<T extends StatefulWidget> extends State<T> {
  RxDouble? _barOffset;
  RxBool? _showTopBar;
  RxBool? _showBottomBar;
  final _mainController = Get.find<MainBarState>();

  // ignore: unused_field
  Ref? _ref;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during state initialization.
  void attachRef(Ref ref) { _ref = ref; }

  bool get needsCorrection => false;

  @override
  void initState() {
    super.initState();
    _barOffset = _mainController.barOffset;
    _showBottomBar = _mainController.showBottomBar;
    try {
      _showTopBar = Get.find<HomeBarState>().showTopBar;
    } catch (_) {}
  }

  Widget onBuild(Widget child) {
    if (_barOffset != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: onNotificationType2,
        child: child,
      );
    }
    if (_showTopBar != null || _showBottomBar != null) {
      return NotificationListener<UserScrollNotification>(
        onNotification: onNotificationType1,
        child: child,
      );
    }
    return child;
  }

  bool onNotificationType1(UserScrollNotification notification) {
    if (!_mainController.useBottomNav) return false;
    if (notification.metrics.axis == .horizontal) return false;
    switch (notification.direction) {
      case .forward:
        _showTopBar?.value = true;
        _showBottomBar?.value = true;
      case .reverse:
        _showTopBar?.value = false;
        _showBottomBar?.value = false;
      case _:
    }
    return false;
  }

  void _updateOffset(double scrollDelta) {
    _barOffset!.value = clampDouble(
      _barOffset!.value + scrollDelta,
      0.0,
      Style.topBarHeight,
    );
  }

  bool onNotificationType2(ScrollNotification notification) {
    if (!_mainController.useBottomNav) return false;

    final metrics = notification.metrics;
    if (metrics.axis == .horizontal) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails == null) return false;
      final pixel = metrics.pixels;
      final scrollDelta = notification.scrollDelta ?? 0;
      if (pixel < 0.0 && scrollDelta > 0) return false;
      if (needsCorrection) {
        final value = _barOffset!.value;
        final newValue = clampDouble(
          value + scrollDelta,
          0.0,
          Style.topBarHeight,
        );
        final offset = value - newValue;
        if (offset != 0) {
          _barOffset!.value = newValue;
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
    _barOffset = null;
    _showTopBar = null;
    _showBottomBar = null;
    super.dispose();
  }
}
