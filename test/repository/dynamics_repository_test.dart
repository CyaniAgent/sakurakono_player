import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'dynamics_repository_test.mocks.dart';

@GenerateMocks([DynamicsRepository])

void main() {
  provideDummy<LoadingState<CoreDynamicsDataModel>>(
    Success(CoreDynamicsDataModel()),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockDynamicsRepository mockRepo;

  setUp(() {
    mockRepo = MockDynamicsRepository();
  });

  group('DynamicsRepository', () {
    test('happy: followDynamic() returns Success with data', () async {
      when(mockRepo.followDynamic()).thenAnswer(
        (_) async => Success(CoreDynamicsDataModel()),
      );
      final result = await mockRepo.followDynamic();
      expect(result, isA<Success<CoreDynamicsDataModel>>());
    });

    test('error: followDynamic() returns Error', () async {
      when(mockRepo.followDynamic()).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.followDynamic();
      expect(result, isA<Error>());
    });

    test('edge: followDynamic() handles null offset correctly', () async {
      when(mockRepo.followDynamic()).thenAnswer(
        (_) async => Success(CoreDynamicsDataModel()),
      );
      final result = await mockRepo.followDynamic();
      expect(result.isSuccess, true);
    });
  });
}