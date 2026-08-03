import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/bilibili/models/model_avatar.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/core/models/follow_item.dart';

void main() {
  group('ModelConverters.followItem officialVerify', () {
    test('map payload round-trips to typed BaseOfficialVerify', () {
      final item = CoreFollowItemModel(officialVerify: <String, dynamic>{
        'type': 0,
        'desc': '达人',
      });
      final result = ModelConverters.followItem(item);
      expect(result.officialVerify, isNotNull);
      expect(result.officialVerify, isA<BaseOfficialVerify>());
      expect(result.officialVerify!.type, 0);
      expect(result.officialVerify!.desc, '达人');
    });

    test('legacy non-map payload (0) converts to null', () {
      final item = CoreFollowItemModel(officialVerify: 0);
      final result = ModelConverters.followItem(item);
      expect(result.officialVerify, isNull);
    });

    test('null officialVerify converts to null', () {
      final item = CoreFollowItemModel(officialVerify: null);
      final result = ModelConverters.followItem(item);
      expect(result.officialVerify, isNull);
    });
  });
}
