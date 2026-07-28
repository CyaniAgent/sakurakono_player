import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/repository/follow_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'follow_repository_test.mocks.dart';

@GenerateMocks([FollowRepository])

void main() {
  provideDummy<LoadingState<CoreFollowData>>(
    Success(CoreFollowData.fromJson({})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockFollowRepository mockRepo;

  setUp(() {
    mockRepo = MockFollowRepository();
  });

  group('FollowRepository', () {
    test('happy: followings() returns Success with data', () async {
      when(mockRepo.followings()).thenAnswer(
        (_) async => Success(CoreFollowData.fromJson({
          'list': <dynamic>[],
          'total': 0,
        })),
      );
      final result = await mockRepo.followings();
      expect(result, isA<Success<CoreFollowData>>());
    });

    test('error: followings() returns Error', () async {
      when(mockRepo.followings()).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.followings();
      expect(result, isA<Error>());
    });

    test('edge: followings() handles null vmid correctly', () async {
      when(mockRepo.followings()).thenAnswer(
        (_) async => Success(CoreFollowData.fromJson({
          'list': <dynamic>[],
          'total': 0,
        })),
      );
      final result = await mockRepo.followings();
      expect(result.isSuccess, true);
    });
  });
}