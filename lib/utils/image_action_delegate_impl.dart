import 'package:flutter/material.dart';
import 'package:skf/core/models/ui/image_action_delegate.dart';
import 'package:skf/core/models/ui/image_preview_type.dart';
import 'package:skf/core/utils/image_action_registry.dart';

/// Default implementation of [CoreImageActionDelegate] that delegates
/// to implementations registered via [ImageActionRegistry].
///
/// When no adapter implementation is registered (e.g. during app startup),
/// all methods are safe no-ops.
class DefaultImageActionDelegate implements CoreImageActionDelegate {
  const DefaultImageActionDelegate();

  @override
  void imageView({
    int initialPage = 0,
    required List<CoreSourceModel> imgList,
    int? quality,
    ValueChanged<int>? onPageChanged,
    String tag = '',
  }) {
    ImageActionRegistry.imageView(
      initialPage: initialPage,
      imgList: imgList,
      quality: quality,
      onPageChanged: onPageChanged,
      tag: tag,
    );
  }

  @override
  void onHorizontalPreviewState(
    ScaffoldState state,
    List<CoreSourceModel> imgList,
    int index,
  ) {
    ImageActionRegistry.onHorizontalPreviewState(state, imgList, index);
  }

  @override
  Future<bool> downloadLivePhoto({
    required String url,
    required String liveUrl,
    required int width,
    required int height,
  }) {
    return ImageActionRegistry.downloadLivePhoto(
      url: url,
      liveUrl: liveUrl,
      width: width,
      height: height,
    );
  }

  @override
  Future<void> launchURL(String url) {
    return ImageActionRegistry.launchURL(url);
  }
}
