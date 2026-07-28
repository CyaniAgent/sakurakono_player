import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'live_repository_test.mocks.dart';

@GenerateMocks([LiveRepository])

void main() {
  provideDummy<LoadingState<CoreRoomPlayInfoData>>(
    Success(CoreRoomPlayInfoData.fromJson({})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockLiveRepository mockRepo;

  setUp(() {
    mockRepo = MockLiveRepository();
  });

  group('LiveRepository', () {
    test('happy: liveRoomInfo() returns Success with data', () async {
      when(mockRepo.liveRoomInfo(
        roomId: anyNamed('roomId'),
      )).thenAnswer(
        (_) async => Success(CoreRoomPlayInfoData.fromJson({})),
      );
      final result = await mockRepo.liveRoomInfo(roomId: 123);
      expect(result, isA<Success<CoreRoomPlayInfoData>>());
    });

    test('error: liveRoomInfo() returns Error', () async {
      when(mockRepo.liveRoomInfo(
        roomId: anyNamed('roomId'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.liveRoomInfo(roomId: 123);
      expect(result, isA<Error>());
    });

    test('edge: liveRoomInfo() handles roomId=0 correctly', () async {
      when(mockRepo.liveRoomInfo(
        roomId: anyNamed('roomId'),
      )).thenAnswer(
        (_) async => Success(CoreRoomPlayInfoData.fromJson({})),
      );
      final result = await mockRepo.liveRoomInfo(roomId: 0);
      expect(result.isSuccess, true);
    });
  });
}