import '../base_api.dart';
import '../models/danmaku/danmaku_item.dart';

/// 弹幕模块接口。
///
/// 提供弹幕的获取、发送、删除功能。
abstract class IDanmakuApi {
  /// 获取指定视频的全部弹幕。
  ///
  /// [vid]: 视频 ID。
  Future<List<DanmakuItem>> getDanmaku(int vid);

  /// 发送弹幕。
  ///
  /// [vid]: 视频 ID。
  /// [text]: 弹幕文字。
  /// [time]: 弹幕出现时间（秒）。
  /// [mode]: 弹幕模式，如 `"scroll"`、`"top"`、`"bottom"`。
  /// [color]: 颜色，如 `"#FFFFFF"`。
  /// [fontSize]: 字号。
  /// [render]: 渲染模式。
  Future<void> sendDanmaku({
    required int vid,
    required String text,
    required double time,
    required String mode,
    required String color,
    required String fontSize,
    required String render,
  });

  /// 删除指定弹幕。
  Future<void> deleteDanmaku(int danmakuId);
}

class DanmakuApi extends BaseApi implements IDanmakuApi {
  DanmakuApi(super.dio, super.getToken, {super.config});

  @override
  Future<List<DanmakuItem>> getDanmaku(int vid) async {
    final response = await get('/danmaku/$vid');
    final list = response['data'] as List<dynamic>;
    return list
        .map((e) => DanmakuItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> sendDanmaku({
    required int vid,
    required String text,
    required double time,
    required String mode,
    required String color,
    required String fontSize,
    required String render,
  }) async {
    await post('/danmaku', auth: true, data: {
      'vid': vid,
      'text': text,
      'time': time,
      'mode': mode,
      'color': color,
      'font_size': fontSize,
      'render': render,
    });
  }

  @override
  Future<void> deleteDanmaku(int danmakuId) async {
    final params = <String, dynamic>{};
    await delete('/danmaku/$danmakuId', auth: true, queryParameters: params);
  }
}
