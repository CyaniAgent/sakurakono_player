import 'package:flutter/material.dart';
import 'package:skf/core/models/ui/image_preview_type.dart';

/// Type definitions for image action callbacks.
typedef ImageViewCallback = void Function({
  int initialPage,
  required List<CoreSourceModel> imgList,
  int? quality,
  ValueChanged<int>? onPageChanged,
  String tag,
});

typedef HorizontalPreviewCallback = void Function(
  ScaffoldState state,
  List<CoreSourceModel> imgList,
  int index,
);

typedef DownloadLivePhotoCallback = Future<bool> Function({
  required String url,
  required String liveUrl,
  required int width,
  required int height,
});

typedef LaunchURLCallback = Future<void> Function(String url);

/// Registry for image action implementations.
///
/// Adapter code (e.g. [BiliBridge]) should call [register] during
/// initialization to wire up the platform-specific implementations.
/// When no implementation is registered the default [DefaultImageActionDelegate]
/// will be a no-op (safe fallback).
abstract final class ImageActionRegistry {
  static _Impl? _impl;

  /// Register the callbacks that implement image actions.
  static void register({
    required ImageViewCallback imageView,
    required HorizontalPreviewCallback onHorizontalPreview,
    required DownloadLivePhotoCallback downloadLivePhoto,
    required LaunchURLCallback launchURL,
  }) {
    _impl = _Impl(
      imageView: imageView,
      onHorizontalPreview: onHorizontalPreview,
      downloadLivePhoto: downloadLivePhoto,
      launchURL: launchURL,
    );
  }

  /// Get the registered implementation, or null if none is registered.
  static _Impl? _get() => _impl;

  /// Delegate to the registered [imageView] callback.
  static void imageView({
    int initialPage = 0,
    required List<CoreSourceModel> imgList,
    int? quality,
    ValueChanged<int>? onPageChanged,
    String tag = '',
  }) {
    _get()?.imageView(
      initialPage: initialPage,
      imgList: imgList,
      quality: quality,
      onPageChanged: onPageChanged,
      tag: tag,
    );
  }

  /// Delegate to the registered [onHorizontalPreview] callback.
  static void onHorizontalPreviewState(
    ScaffoldState state,
    List<CoreSourceModel> imgList,
    int index,
  ) {
    _get()?.onHorizontalPreview(state, imgList, index);
  }

  /// Delegate to the registered [downloadLivePhoto] callback.
  static Future<bool> downloadLivePhoto({
    required String url,
    required String liveUrl,
    required int width,
    required int height,
  }) {
    final impl = _get();
    if (impl != null) {
      return impl.downloadLivePhoto(
        url: url,
        liveUrl: liveUrl,
        width: width,
        height: height,
      );
    }
    return Future<bool>.value(false);
  }

  /// Delegate to the registered [launchURL] callback.
  static Future<void> launchURL(String url) {
    final impl = _get();
    if (impl != null) {
      return impl.launchURL(url);
    }
    return Future<void>.value();
  }
}

/// Internal holder class for the registered callbacks.
class _Impl {
  final ImageViewCallback imageView;
  final HorizontalPreviewCallback onHorizontalPreview;
  final DownloadLivePhotoCallback downloadLivePhoto;
  final LaunchURLCallback launchURL;

  const _Impl({
    required this.imageView,
    required this.onHorizontalPreview,
    required this.downloadLivePhoto,
    required this.launchURL,
  });
}
