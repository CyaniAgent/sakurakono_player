import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/danmaku_types.dart';
import 'package:skf/core/repository/danmaku_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'danmaku_repository_test.mocks.dart';

@GenerateMocks([DanmakuRepository])

void main() {
  provideDummy<LoadingState<CoreDanmakuSegmentReply>>(Success(CoreDanmakuSegmentReply()));
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockDanmakuRepository mockRepo;

  setUp(() {
    mockRepo = MockDanmakuRepository();
  });

  group('DanmakuRepository', () {
    test('happy: dmSegMobile() returns Success with data', () async {
      when(mockRepo.dmSegMobile(
        cid: anyNamed('cid'),
        segmentIndex: anyNamed('segmentIndex'),
      )).thenAnswer((_) async => Success(CoreDanmakuSegmentReply()));
      final result = await mockRepo.dmSegMobile(cid: 1, segmentIndex: 1);
      expect(result, isA<Success<CoreDanmakuSegmentReply>>());
    });

    test('error: dmSegMobile() returns Error', () async {
      when(mockRepo.dmSegMobile(
        cid: anyNamed('cid'),
        segmentIndex: anyNamed('segmentIndex'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.dmSegMobile(cid: 1, segmentIndex: 1);
      expect(result, isA<Error>());
    });

    test('edge: dmSegMobile() handles cid=0 correctly', () async {
      when(mockRepo.dmSegMobile(
        cid: anyNamed('cid'),
        segmentIndex: anyNamed('segmentIndex'),
      )).thenAnswer((_) async => Success(CoreDanmakuSegmentReply()));
      final result = await mockRepo.dmSegMobile(cid: 0, segmentIndex: 0);
      expect(result.isSuccess, true);
    });
  });
}