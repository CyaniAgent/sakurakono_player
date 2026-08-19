import 'package:flutter_test/flutter_test.dart';
import 'package:skf/router/app_navigator.dart';

void main() {
  group('AppNavigator.isDuplicate', () {
    test('same path, no query -> true', () {
      expect(AppNavigator.isDuplicate(Uri.parse('/videoV'), '/videoV'), isTrue);
    });

    test('same path + same query -> true', () {
      expect(
        AppNavigator.isDuplicate(Uri.parse('/videoV?mid=123'), '/videoV?mid=123'),
        isTrue,
      );
    });

    test('same path + different query -> false (regression)', () {
      expect(
        AppNavigator.isDuplicate(Uri.parse('/videoV?mid=456'), '/videoV?mid=123'),
        isFalse,
      );
    });

    test('different path -> false', () {
      expect(AppNavigator.isDuplicate(Uri.parse('/videoV'), '/member'), isFalse);
    });

    test('null current -> false', () {
      expect(AppNavigator.isDuplicate(Uri.parse('/videoV'), null), isFalse);
    });
  });

  group('AppNavigator.buildUri', () {
    test('no parameters -> path unchanged', () {
      expect(AppNavigator.buildUri('/videoV', null), Uri.parse('/videoV'));
    });

    test('parameters appended as query', () {
      expect(
        AppNavigator.buildUri('/videoV', {'mid': '123'}),
        Uri.parse('/videoV?mid=123'),
      );
    });

    test('pre-existing query preserved and merged', () {
      expect(
        AppNavigator.buildUri('/videoV?mid=123', {'page': '2'}),
        Uri.parse('/videoV?mid=123&page=2'),
      );
    });
  });
}