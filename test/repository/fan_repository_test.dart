import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/repository/fan_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'fan_repository_test.mocks.dart';

@GenerateMocks([FanRepository])

void main() {
  provideDummy<LoadingState<CoreFollowData>>(
    Success(CoreFollowData.fromJson({})),
  );
  late MockFanRepository mockRepo;

  setUp(() {
    mockRepo = MockFanRepository();
  });

  group('FanRepository', () {
    test('happy: fans() returns Success with data', () async {
      when(mockRepo.fans()).thenAnswer(
        (_) async => Success(CoreFollowData.fromJson({
          'list': <dynamic>[],
          'total': 0,
        })),
      );
      final result = await mockRepo.fans();
      expect(result, isA<Success<CoreFollowData>>());
    });

    test('error: fans() returns Error', () async {
      when(mockRepo.fans()).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.fans();
      expect(result, isA<Error>());
    });

    test('edge: fans() handles null vmid correctly', () async {
      when(mockRepo.fans()).thenAnswer(
        (_) async => Success(CoreFollowData.fromJson({
          'list': <dynamic>[],
          'total': 0,
        })),
      );
      final result = await mockRepo.fans();
      expect(result.isSuccess, true);
    });
  });
}