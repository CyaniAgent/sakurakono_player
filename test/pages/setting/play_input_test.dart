import 'package:flutter_test/flutter_test.dart';
import 'package:skf/pages/setting/play_input.dart';

void main() {
  group('classifyPlayInput', () {
    test('B站 视频 URL 识别为 biliUrl', () {
      expect(
        classifyPlayInput('https://www.bilibili.com/video/BV1xx411c7mD'),
        PlayInputKind.biliUrl,
      );
    });

    test('b23.tv 短链识别为 biliUrl', () {
      expect(classifyPlayInput('b23.tv/abc123'), PlayInputKind.biliUrl);
    });

    test('bilibili:// scheme 识别为 biliUrl', () {
      expect(
        classifyPlayInput('bilibili://video/123456'),
        PlayInputKind.biliUrl,
      );
    });

    test('裸 BV 号识别为 biliUrl', () {
      expect(classifyPlayInput('BV1xx411c7mD'), PlayInputKind.biliUrl);
    });

    test('裸 av 号识别为 biliUrl', () {
      expect(classifyPlayInput('av123456'), PlayInputKind.biliUrl);
    });

    test('live.bilibili.com URL 识别为 biliUrl', () {
      expect(classifyPlayInput('live.bilibili.com/12345'), PlayInputKind.biliUrl);
    });

    test('全数字识别为 ottoVid', () {
      expect(classifyPlayInput('123456'), PlayInputKind.ottoVid);
    });

    test('普通字符串识别为 unknown', () {
      expect(classifyPlayInput('hello'), PlayInputKind.unknown);
    });

    test('空串识别为 unknown', () {
      expect(classifyPlayInput(''), PlayInputKind.unknown);
    });

    test('纯空白识别为 unknown', () {
      expect(classifyPlayInput('   '), PlayInputKind.unknown);
    });

    test('含空格的数字识别为 unknown（钉死规则）', () {
      expect(classifyPlayInput('123 456'), PlayInputKind.unknown);
    });

    test('含空格的 BV 号识别为 unknown（钉死规则）', () {
      expect(classifyPlayInput('BV1xx 411c7mD'), PlayInputKind.unknown);
    });

    test('trim 后判定：带首尾空白仍分类正确', () {
      expect(
        classifyPlayInput('  BV1xx411c7mD  '),
        PlayInputKind.biliUrl,
      );
      expect(classifyPlayInput('  123456  '), PlayInputKind.ottoVid);
    });
  });
}
