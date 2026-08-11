import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/ottohub/bridge.dart';
import 'package:skf/core/adapter/app_adapter.dart';

void main() {
  group('OttoAdapter.hasFeature', () {
    final adapter = OttoAdapter();

    test('search => true', () => expect(adapter.hasFeature(AppFeature.search), true));
    test('space => true', () => expect(adapter.hasFeature(AppFeature.space), true));
    test('download => true', () => expect(adapter.hasFeature(AppFeature.download), true));
    test('validate => true', () => expect(adapter.hasFeature(AppFeature.validate), true));
    test('danmakuFilter => true', () => expect(adapter.hasFeature(AppFeature.danmakuFilter), true));
  });
}
