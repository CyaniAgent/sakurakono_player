import 'package:flutter/material.dart';
import 'package:skf/core/models/ui/image_preview_type.dart';

/// Delegate for image actions that may be adapter-specific.
///
/// [ImageGridView] uses this delegate to perform actions like
/// opening the image viewer, showing horizontal previews,
/// downloading live photos, and launching URLs.
/// The default implementation ([DefaultImageActionDelegate]) wraps
/// the Bilibili adapter implementations.
abstract class CoreImageActionDelegate {
  void imageView({
    int initialPage = 0,
    required List<CoreSourceModel> imgList,
    int? quality,
    ValueChanged<int>? onPageChanged,
    String tag = '',
  });

  void onHorizontalPreviewState(
    ScaffoldState state,
    List<CoreSourceModel> imgList,
    int index,
  );

  Future<bool> downloadLivePhoto({
    required String url,
    required String liveUrl,
    required int width,
    required int height,
  });

  Future<void> launchURL(String url);
}