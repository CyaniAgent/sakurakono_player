import 'package:get/get.dart' show GetPage;
import 'package:skf/core/adapter/play_input_kind.dart';
import 'package:skf/core/models/media_id.dart';

/// Abstract interface for a platform adapter (Bilibili, OttoHub, etc.).
abstract class AppAdapter {
  String get name;

  /// Adapter-specific startup BEFORE generic storage init (Hive TypeAdapter
  /// registration etc.). Runs before [GStorage.init]; must not touch Hive
  /// boxes or GetX DI. Default no-op.
  Future<void> onAppStartPreStorage() async {}

  /// Adapter-specific startup AFTER generic storage init (account bootstrap
  /// etc.). Runs before the adapter's DI registration. Default no-op.
  Future<void> onAppStart() async {}

  /// Register all DI bindings for this adapter via GetX.
  Future<void> registerDependencies();

  /// Adapter-specific routes.
  List<GetPage> get routes;

  /// Process an image URL for display.
  /// Bilibili adapter adds CDN quality params (@1q.webp etc).
  /// OttoHub adapter returns the original URL unchanged.
  String processImageUrl(String? originalUrl, {int quality = 1});

  /// Builds a shareable link for a media item, or null if the adapter
  /// has no share-link concept for it (e.g. pure-numeric platforms).
  String? buildShareLink(CoreMediaId id, {String? title}) => null;

  /// Open a deep link or URL using adapter-specific scheme handling.
  /// Bilibili resolves `bilibili://` and bilibili.com URLs; adapters without
  /// a scheme concept return false (unhandled).
  Future<bool> openUrl(String url, {int? businessId, int? oid}) =>
      Future.syncValue(false);

  /// Classify a trimmed playback input string (设置页「播放链接」).
  /// Adapters return [PlayInputKind.videoUrl] for URLs/IDs they can route
  /// via [openUrl], [PlayInputKind.numericId] for pure-numeric video IDs,
  /// otherwise [PlayInputKind.unknown]. Default: unknown.
  PlayInputKind classifyPlayInput(String input) => PlayInputKind.unknown;
}
