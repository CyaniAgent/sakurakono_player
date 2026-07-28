import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'im_repository_test.mocks.dart';

@GenerateMocks([ImRepository])

void main() {
  provideDummy<LoadingState<CoreImRspSendMsg>>(const Success(CoreImRspSendMsg()));
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockImRepository mockRepo;

  setUp(() {
    mockRepo = MockImRepository();
  });

  group('ImRepository', () {
    test('happy: sendMsg() returns Success with data', () async {
      when(mockRepo.sendMsg(
        senderUid: anyNamed('senderUid'),
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
      )).thenAnswer((_) async => const Success(CoreImRspSendMsg()));
      final result = await mockRepo.sendMsg(
        senderUid: 1, receiverId: 2, content: 'hello',
      );
      expect(result, isA<Success<CoreImRspSendMsg>>());
    });

    test('error: sendMsg() returns Error', () async {
      when(mockRepo.sendMsg(
        senderUid: anyNamed('senderUid'),
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.sendMsg(
        senderUid: 1, receiverId: 2, content: 'hello',
      );
      expect(result, isA<Error>());
    });

    test('edge: sendMsg() handles empty content correctly', () async {
      when(mockRepo.sendMsg(
        senderUid: anyNamed('senderUid'),
        receiverId: anyNamed('receiverId'),
        content: anyNamed('content'),
      )).thenAnswer((_) async => const Success(CoreImRspSendMsg()));
      final result = await mockRepo.sendMsg(
        senderUid: 0, receiverId: 0, content: '',
      );
      expect(result.isSuccess, true);
    });
  });
}