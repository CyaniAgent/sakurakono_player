import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_types.freezed.dart';

/// Generic app-level update information (adapter-agnostic).
///
/// Produced by [AppRepository.checkUpdate] — every adapter maps its own
/// update mechanism (or absence of one) into this shape.
@freezed
abstract class CoreUpdateInfo with _$CoreUpdateInfo {
  const factory CoreUpdateInfo({
    @Default(false) bool hasUpdate,
    String? latestVersion,
    String? downloadUrl,
    String? releaseNotes,
    String? publishedAt,
  }) = _CoreUpdateInfo;
}

/// One home-page slideshow (carousel) entry.
///
/// [href] is an opaque deep link owned by the adapter's site (e.g. a video or
/// blog permalink); routing is resolved adapter-side.
///
/// [width]/[height] 为封面宽高比的探测值(适配器 16px 降采样解码,比例
/// 精确、非原始像素),服务端无此字段,由适配器尽力上报;为 null 时 UI
/// 按视口推导高度。轮播取首条的比例决定整体高度。
@freezed
abstract class CoreSlide with _$CoreSlide {
  const factory CoreSlide({
    required String imgUrl,
    String? title,
    String? href,
    int? width,
    int? height,
  }) = _CoreSlide;
}
