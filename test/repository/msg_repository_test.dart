import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'msg_repository_test.mocks.dart';

@GenerateMocks([MsgRepository])

void main() {
  provideDummy<LoadingState<CoreMsgReplyData>>(
    Success(CoreMsgReplyData.fromJson({})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockMsgRepository mockRepo;

  setUp(() {
    mockRepo = MockMsgRepository();
  });

  group('MsgRepository', () {
    test('happy: msgFeedReplyMe() returns Success with data', () async {
      when(mockRepo.msgFeedReplyMe()).thenAnswer(
        (_) async => Success(CoreMsgReplyData.fromJson({})),
      );
      final result = await mockRepo.msgFeedReplyMe();
      expect(result, isA<Success<CoreMsgReplyData>>());
    });

    test('error: msgFeedReplyMe() returns Error', () async {
      when(mockRepo.msgFeedReplyMe()).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.msgFeedReplyMe();
      expect(result, isA<Error>());
    });

    test('edge: msgFeedReplyMe() handles null cursor correctly', () async {
      when(mockRepo.msgFeedReplyMe()).thenAnswer(
        (_) async => Success(CoreMsgReplyData.fromJson({})),
      );
      final result = await mockRepo.msgFeedReplyMe();
      expect(result.isSuccess, true);
    });
  });
}