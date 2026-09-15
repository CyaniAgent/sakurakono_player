import 'package:flutter/foundation.dart';

/// 全局 App 壳刷新通知器。
///
/// 设置项（主题、纯黑模式、字体字重、UI 缩放、页面过渡动画）变更后调用
/// [refresh]，由 main.dart 中包裹 MaterialApp 的 ListenableBuilder 监听重建，
/// 重读 Pref 使设置即时生效。替代 GetX 时代的
/// `Get.appUpdate()` / `Get.updateMyAppTheme()` / `Get.changeThemeMode()`。
final AppRefresh appRefresh = AppRefresh();

class AppRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}
