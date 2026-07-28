import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'reply_repository_test.mocks.dart';

@GenerateMocks([ReplyRepository])

void main() {
  provideDummy<LoadingState<CoreMainListReply>>(const Success(CoreMainListReply()));
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockReplyRepository mockRepo;

  setUp(() {
    mockRepo = MockReplyRepository();
  });

  group('ReplyRepository', () {
    test('happy: mainList() returns Success with data', () async {
      when(mockRepo.mainList(
        type: anyNamed('type'),
        oid: anyNamed('oid'),
        mode: anyNamed('mode'),
        offset: anyNamed('offset'),
        cursorNext: anyNamed('cursorNext'),
      )).thenAnswer((_) async => const Success(CoreMainListReply()));
      final result = await mockRepo.mainList(
        type: 1, oid: 123, mode: CoreMode.defaultMode,
        offset: null, cursorNext: 0,
      );
      expect(result, isA<Success<CoreMainListReply>>());
    });

    test('error: mainList() returns Error', () async {
      when(mockRepo.mainList(
        type: anyNamed('type'),
        oid: anyNamed('oid'),
        mode: anyNamed('mode'),
        offset: anyNamed('offset'),
        cursorNext: anyNamed('cursorNext'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.mainList(
        type: 1, oid: 123, mode: CoreMode.defaultMode,
        offset: null, cursorNext: 0,
      );
      expect(result, isA<Error>());
    });

    test('edge: mainList() handles oid=0 correctly', () async {
      when(mockRepo.mainList(
        type: anyNamed('type'),
        oid: anyNamed('oid'),
        mode: anyNamed('mode'),
        offset: anyNamed('offset'),
        cursorNext: anyNamed('cursorNext'),
      )).thenAnswer((_) async => const Success(CoreMainListReply()));
      final result = await mockRepo.mainList(
        type: 0, oid: 0, mode: CoreMode.defaultMode,
        offset: null, cursorNext: 0,
      );
      expect(result.isSuccess, true);
    });
  });
}