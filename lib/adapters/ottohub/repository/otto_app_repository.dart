import 'dart:async';
import 'dart:io' show HttpClient;
import 'dart:typed_data' show BytesBuilder;
import 'dart:ui' as ui show instantiateImageCodec;

import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/repository/app_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// [AppRepository] for OttoHub.
///
/// OttoHub has no update mechanism — there is no release channel to check,
/// so [checkUpdate] always reports "no update". The slideshow comes from the
/// old system module (`/system/slideshow`).
class OttoAppRepository implements AppRepository {
  OttoAppRepository(
    this._api, {
    Future<(int, int)?> Function(String url)? probeImageSize,
  }) : _probeImageSize = probeImageSize ?? _defaultProbeImageSize;

  final OttohubClient _api;

  /// 封面尺寸探测(服务端 slideshow 无宽高字段):取首条封面按 16px 降采样
  /// 解码读出真实比例,轮播据此推导高度。可注入替换/置空(测试离线)。
  final Future<(int, int)?> Function(String url) _probeImageSize;

  static Future<(int, int)?> _defaultProbeImageSize(String url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final bytes =
          (await response.fold(BytesBuilder(), (b, d) => b..add(d)))
              .takeBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 16);
      final frame = await codec.getNextFrame();
      return (frame.image.width, frame.image.height);
    } catch (_) {
      // 探测失败(离线/超时/非图片)不阻塞轮播,交由 UI 按视口推导。
      return null;
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<LoadingState<CoreUpdateInfo>> checkUpdate({
    String? currentVersion,
  }) async =>
      const Success(CoreUpdateInfo(hasUpdate: false));

  @override
  Future<LoadingState<List<CoreSlide>>> slideshow() async {
    try {
      final slides = await _api.oldSystem.getSlideshow();
      final coreSlides =
          slides
              .map(
                (s) => CoreSlide(
                  imgUrl: s.imgUrl,
                  title: s.title,
                  href: s.href,
                ),
              )
              .toList();
      // 轮播整体高度由首条封面的真实比例决定:尽力探测一次(4s 超时),
      // 失败则不上报,UI 退回按视口推导。
      if (coreSlides.isNotEmpty) {
        final Future<(int, int)?> probe =
            _probeImageSize(coreSlides.first.imgUrl);
        (int, int)? size;
        try {
          size = await probe.timeout(const Duration(seconds: 4));
        } on Exception {
          // 探测失败/超时不阻塞轮播,交由 UI 按视口推导。
          size = null;
        }
        if (size != null) {
          coreSlides[0] = coreSlides[0].copyWith(
            width: size.$1,
            height: size.$2,
          );
        }
      }
      return Success(coreSlides);
    } on ApiException catch (e) {
      return Error(e.errorCode, code: e.httpStatus);
    } catch (e) {
      // SDK 对非 success 响应直接解包 data(可能抛类型错误):统一降级错误态。
      return Error(e.toString());
    }
  }
}
