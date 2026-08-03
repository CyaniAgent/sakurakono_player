import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/ottohub/bridge.dart';
import 'package:skf/core/adapter/app_adapter.dart';

void main() {
  group('OttoAdapter.hasFeature', () {
    final adapter = OttoAdapter();

    test('search => false', () => expect(adapter.hasFeature(AppFeature.search), false));
    test('space => false', () => expect(adapter.hasFeature(AppFeature.space), false));
    test('download => false', () => expect(adapter.hasFeature(AppFeature.download), false));
    test('validate => false', () => expect(adapter.hasFeature(AppFeature.validate), false));
    test('danmakuFilter => false', () => expect(adapter.hasFeature(AppFeature.danmakuFilter), false));
  });
}
