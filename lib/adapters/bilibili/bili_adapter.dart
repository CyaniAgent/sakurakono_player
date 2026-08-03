import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:skf/adapters/bilibili/pages/main/view.dart';
import 'package:skf/core/adapter/app_adapter.dart';
import 'package:skf/utils/image_utils.dart';

class BiliAdapter implements AppAdapter {
  @override
  String get name => 'bilibili';

  @override
  String get displayName => 'Bilibili';

  @override
  Future<void> registerDependencies() async {
    BiliBridge.register();
  }

  @override
  List<GetPage> get routes => BiliBridge.registerRoutes();

  @override
  bool hasFeature(AppFeature feature) => true; // Bilibili supports everything

  @override
  Widget get homePage => const MainApp();

  @override
  Future<void> onInit() async {
    // Bilibili-specific initialization is handled by BiliBridge.
  }

  @override
  String processImageUrl(String? originalUrl, {int quality = 1}) {
    return ImageUtils.thumbnailUrl(originalUrl, quality);
  }
}
