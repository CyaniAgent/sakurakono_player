import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:skf/core/adapter/app_adapter.dart';
import 'package:skf/core/models/media_id.dart';
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

  @override
  String? buildShareLink(CoreMediaId id, {String? title}) {
    return switch (id) {
      CoreBvId() => 'https://www.bilibili.com/video/${id.id}',
      CoreAvId() => 'https://www.bilibili.com/video/${id.id}',
      CoreSeasonId() => 'https://www.bilibili.com/bangumi/play/ss${id.id}',
      CoreEpId() => 'https://www.bilibili.com/bangumi/play/ep${id.id}',
      CoreRoomId() => 'https://live.bilibili.com/${id.id}',
      // No share-link concept for cids, generic numeric IDs or local files.
      _ => null,
    };
  }
}
