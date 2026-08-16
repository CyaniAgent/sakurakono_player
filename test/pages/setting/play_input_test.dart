import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/bilibili/bili_adapter.dart';
import 'package:skf/adapters/ottohub/bridge.dart';
import 'package:skf/core/adapter/play_input_kind.dart';

/// 契约测试：分类逻辑由各适配器的 `classifyPlayInput` 提供
/// （AppAdapter 契约），共享层只按 PlayInputKind 分派。
void main() {
  group('BiliAdapter.classifyPlayInput', () {
    final adapter = BiliAdapter();

    test('B站 视频 URL 识别为 videoUrl', () {
      expect(
        adapter.classifyPlayInput('https://www.bilibili.com/video/BV1xx411c7mD'),
        PlayInputKind.videoUrl,
      );
    });

    test('短链（b23.tv）识别为 videoUrl', () {
      expect(adapter.classifyPlayInput('b23.tv/abc123'), PlayInputKind.videoUrl);
    });

    test('bilibili:// scheme 识别为 videoUrl', () {
      expect(
        adapter.classifyPlayInput('bilibili://video/123456'),
        PlayInputKind.videoUrl,
      );
    });

    test('裸 BV 号识别为 videoUrl', () {
      expect(adapter.classifyPlayInput('BV1xx411c7mD'), PlayInputKind.videoUrl);
    });

    test('裸 av 号识别为 videoUrl', () {
      expect(adapter.classifyPlayInput('av123456'), PlayInputKind.videoUrl);
    });

    test('live.bilibili.com URL 识别为 videoUrl', () {
      expect(
        adapter.classifyPlayInput('live.bilibili.com/12345'),
        PlayInputKind.videoUrl,
      );
    });

    test('全数字识别为 numericId', () {
      expect(adapter.classifyPlayInput('123456'), PlayInputKind.numericId);
    });

    test('普通字符串识别为 unknown', () {
      expect(adapter.classifyPlayInput('hello'), PlayInputKind.unknown);
    });

    test('空串识别为 unknown', () {
      expect(adapter.classifyPlayInput(''), PlayInputKind.unknown);
    });

    test('纯空白识别为 unknown', () {
      expect(adapter.classifyPlayInput('   '), PlayInputKind.unknown);
    });

    test('含空格的数字识别为 unknown（钉死规则）', () {
      expect(adapter.classifyPlayInput('123 456'), PlayInputKind.unknown);
    });

    test('含空格的 BV 号识别为 unknown（钉死规则）', () {
      expect(adapter.classifyPlayInput('BV1xx 411c7mD'), PlayInputKind.unknown);
    });

    test('trim 后判定：带首尾空白仍分类正确', () {
      expect(
        adapter.classifyPlayInput('  BV1xx411c7mD  '),
        PlayInputKind.videoUrl,
      );
      expect(adapter.classifyPlayInput('  123456  '), PlayInputKind.numericId);
    });
  });

  group('OttoAdapter.classifyPlayInput', () {
    final adapter = OttoAdapter();

    test('全数字识别为 numericId', () {
      expect(adapter.classifyPlayInput('123456'), PlayInputKind.numericId);
    });

    test('B站 URL 识别为 unknown（无法路由，与分派 toast 一致）', () {
      expect(
        adapter.classifyPlayInput('https://www.bilibili.com/video/BV1xx411c7mD'),
        PlayInputKind.unknown,
      );
    });

    test('普通字符串识别为 unknown', () {
      expect(adapter.classifyPlayInput('hello'), PlayInputKind.unknown);
    });

    test('空串/纯空白识别为 unknown', () {
      expect(adapter.classifyPlayInput(''), PlayInputKind.unknown);
      expect(adapter.classifyPlayInput('   '), PlayInputKind.unknown);
    });

    test('trim 后判定：带首尾空白仍识别为 numericId', () {
      expect(adapter.classifyPlayInput('  123456  '), PlayInputKind.numericId);
    });
  });
}
