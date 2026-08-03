import 'package:flutter/widgets.dart';
import 'package:get/get.dart' show GetPage;

/// Feature flags that can be toggled per adapter.
enum AppFeature {
  search,
  live,
  music,
  danmakuFilter,
  audio,
  match,
  space,
  download,
  pgc,
  sponsorBlock,
  validate,
}

/// Abstract interface for a platform adapter (Bilibili, OttoHub, etc.).
abstract class AppAdapter {
  String get name;
  String get displayName;

  /// Register all DI bindings for this adapter via GetX.
  Future<void> registerDependencies();

  /// Adapter-specific routes.
  List<GetPage> get routes;

  /// Whether this adapter supports the given feature.
  bool hasFeature(AppFeature feature);

  /// The home page widget for this adapter.
  Widget get homePage;

  /// Lifecycle hook called after DI registration.
  Future<void> onInit();

  /// Process an image URL for display.
  /// Bilibili adapter adds CDN quality params (@1q.webp etc).
  /// OttoHub adapter returns the original URL unchanged.
  String processImageUrl(String? originalUrl, {int quality = 1});
}
