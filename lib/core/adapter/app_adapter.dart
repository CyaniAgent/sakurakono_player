import 'package:get/get.dart' show GetPage;
import 'package:skf/core/models/media_id.dart';

/// Abstract interface for a platform adapter (Bilibili, OttoHub, etc.).
abstract class AppAdapter {
  String get name;
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
}
