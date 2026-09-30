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
  }) : _probeImageSize = probeImageSize ?? _defaultProbeImageSize,
       _probeCache = {};

  final OttohubClient _api;

  /// 封面尺寸探测缓存(服务端 slideshow 无宽高字段):URL → (宽, 高)。
  /// 命中缓存零网络零等待;未命中才探测并写缓存。可注入替换(测试离线)。
  final Future<(int, int)?> Function(String url) _probeImageSize;
  final Map<String, (int, int)> _probeCache;

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

  /// 带缓存的探测:命中零等待;未命中探测(4s 超时竞速)后写缓存。
  /// 用 Completer 竞速而非 `timeout(onTimeout:)`——后者会因实际 Future
  /// 的泛型具体化(非空 record)导致 onTimeout 闭包运行时子类型检查失败。
  Future<(int, int)?> _probeWithCache(String url) async {
    final cached = _probeCache[url];
    if (cached != null) return cached;
    final result = Completer<(int, int)?>();
    final timer = Timer(const Duration(seconds: 4), () {
      if (!result.isCompleted) result.complete(null);
    });
    unawaited(
      _probeImageSize(url).then(
        (size) {
          if (size != null) _probeCache[url] = size;
          if (!result.isCompleted) result.complete(size);
        },
        onError: (Object e) {
          if (!result.isCompleted) result.complete(null);
        },
      ),
    );
    final size = await result.future;
    timer.cancel();
    return size;
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
      // 轮播整体高度由首条封面的真实比例决定:带缓存探测(命中零等待),
      // 失败则不上报,UI 退回按视口推导。
      if (coreSlides.isNotEmpty) {
        final size = await _probeWithCache(coreSlides.first.imgUrl);
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
