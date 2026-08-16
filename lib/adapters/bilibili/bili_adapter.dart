import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/app_scheme.dart';
import 'package:skf/core/adapter/app_adapter.dart';
import 'package:skf/core/adapter/play_input_kind.dart';
import 'package:skf/core/models/media_id.dart';
import 'package:skf/adapters/bilibili/utils/bili_image_utils.dart';

class BiliAdapter implements AppAdapter {
  @override
  String get name => 'bilibili';

  @override
  Future<void> onAppStartPreStorage() async {
    // Hive TypeAdapters MUST be registered before GStorage.init().
    BiliBridge.initHive();
  }

  @override
  Future<void> onAppStart() async {
    await Accounts.init();
  }

  @override
  Future<void> registerDependencies() async {
    BiliBridge.register();
  }

  @override
  List<GetPage> get routes => BiliBridge.registerRoutes();

  @override
  String processImageUrl(String? originalUrl, {int quality = 1}) {
    return BiliImageUtils.thumbnailUrl(originalUrl, quality);
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

  @override
  Future<bool> openUrl(String url, {int? businessId, int? oid}) {
    return PiliScheme.routePushFromUrl(
      url,
      businessId: businessId,
      oid: oid,
    );
  }

  @override
  PlayInputKind classifyPlayInput(String input) {
    final value = input.trim();
    if (value.isEmpty) return PlayInputKind.unknown;

    final lower = value.toLowerCase();
    if (lower.contains('bilibili.com') ||
        lower.contains('b23.tv') ||
        lower.startsWith('bilibili://')) {
      return PlayInputKind.videoUrl;
    }
    if (RegExp(r'^bv1[0-9a-zA-Z]{9}$', caseSensitive: false)
        .hasMatch(lower)) {
      return PlayInputKind.videoUrl;
    }
    if (RegExp(r'^av\d+$', caseSensitive: false).hasMatch(lower)) {
      return PlayInputKind.videoUrl;
    }
    if (RegExp(r'^\d+$').hasMatch(lower)) {
      return PlayInputKind.numericId;
    }
    return PlayInputKind.unknown;
  }
}
