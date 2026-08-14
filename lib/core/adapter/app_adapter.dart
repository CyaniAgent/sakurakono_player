import 'package:get/get.dart' show GetPage;

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
}
