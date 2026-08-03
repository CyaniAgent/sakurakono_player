import 'package:flutter_test/flutter_test.dart';
import 'package:skf/utils/num_utils.dart';

void main() {
  group('NumUtils.parseNum', () {
    test('returns 0 for empty string', () {
      expect(NumUtils.parseNum(''), equals(0));
    });

    test('returns 0 for dash', () {
      expect(NumUtils.parseNum('-'), equals(0));
    });

    test('parses plain numbers', () {
      expect(NumUtils.parseNum('12345'), equals(12345));
    });

    test('parses 万 numbers', () {
      expect(NumUtils.parseNum('1.2万'), equals(12000));
    });

    test('parses 亿 numbers', () {
      expect(NumUtils.parseNum('2.5亿'), equals(250000000));
    });

    test('handles null-like string', () {
      expect(NumUtils.parseNum('null'), equals(0));
    });

    test('handles whitespace string', () {
      expect(NumUtils.parseNum('   '), equals(0));
    });
  });
}
