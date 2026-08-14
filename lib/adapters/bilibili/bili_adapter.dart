import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:skf/core/adapter/app_adapter.dart';
import 'package:skf/utils/image_utils.dart';

class BiliAdapter implements AppAdapter {
  @override
  String get name => 'bilibili';

  @override
  Future<void> registerDependencies() async {
    BiliBridge.register();
  }

  @override
  List<GetPage> get routes => BiliBridge.registerRoutes();

  @override
  String processImageUrl(String? originalUrl, {int quality = 1}) {
    return ImageUtils.thumbnailUrl(originalUrl, quality);
  }
}
