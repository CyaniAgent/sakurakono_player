import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/danmaku_block.dart';
import 'package:skf/core/repository/danmaku_filter_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'danmaku_filter_repository_test.mocks.dart';

@GenerateMocks([DanmakuFilterRepository])

void main() {
  provideDummy<LoadingState<CoreDanmakuBlockDataModel>>(
    Success(CoreDanmakuBlockDataModel.fromJson({})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockDanmakuFilterRepository repository;

  setUp(() {
    repository = MockDanmakuFilterRepository();
  });

  group('DanmakuFilterRepository', () {
    test('happy: danmakuFilter() returns Success with data', () async {
      when(repository.danmakuFilter()).thenAnswer(
        (_) async => Success(CoreDanmakuBlockDataModel.fromJson({})),
      );
      final result = await repository.danmakuFilter();
      expect(result, isA<Success<CoreDanmakuBlockDataModel>>());
    });

    test('error: danmakuFilter() returns Error', () async {
      when(repository.danmakuFilter()).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await repository.danmakuFilter();
      expect(result, isA<Error>());
    });

    test('edge: danmakuFilterDel() with ids=0 handles correctly', () async {
      when(repository.danmakuFilterDel(ids: anyNamed('ids'))).thenAnswer(
        (_) async => const Success(null),
      );
      final result = await repository.danmakuFilterDel(ids: 0);
      expect(result.isSuccess, true);
    });
  });
}