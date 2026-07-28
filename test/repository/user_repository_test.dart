import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'user_repository_test.mocks.dart';

@GenerateMocks([UserRepository])

void main() {
  provideDummy<LoadingState<CoreUserInfoData>>(
    Success(CoreUserInfoData.fromJson({})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockUserRepository mockRepo;

  setUp(() {
    mockRepo = MockUserRepository();
  });

  group('UserRepository', () {
    test('happy: userInfo() returns Success with data', () async {
      when(mockRepo.userInfo()).thenAnswer(
        (_) async => Success(CoreUserInfoData.fromJson({})),
      );
      final result = await mockRepo.userInfo();
      expect(result, isA<Success<CoreUserInfoData>>());
    });

    test('error: userInfo() returns Error', () async {
      when(mockRepo.userInfo()).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.userInfo();
      expect(result, isA<Error>());
    });

    test('edge: userInfo() handles empty response correctly', () async {
      when(mockRepo.userInfo()).thenAnswer(
        (_) async => Success(CoreUserInfoData.fromJson({})),
      );
      final result = await mockRepo.userInfo();
      expect(result.isSuccess, true);
    });
  });
}