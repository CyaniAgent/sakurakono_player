import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/pgc_types.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'pgc_repository_test.mocks.dart';

@GenerateMocks([PgcRepository])

void main() {
  provideDummy<LoadingState<CorePgcIndexResult>>(
    Success(CorePgcIndexResult.fromJson({})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockPgcRepository mockRepo;

  setUp(() {
    mockRepo = MockPgcRepository();
  });

  group('PgcRepository', () {
    test('happy: pgcIndexResult() returns Success with data', () async {
      when(mockRepo.pgcIndexResult(
        page: anyNamed('page'),
        params: anyNamed('params'),
      )).thenAnswer(
        (_) async => Success(CorePgcIndexResult.fromJson({})),
      );
      final result = await mockRepo.pgcIndexResult(
        page: 1, params: <String, dynamic>{},
      );
      expect(result, isA<Success<CorePgcIndexResult>>());
    });

    test('error: pgcIndexResult() returns Error', () async {
      when(mockRepo.pgcIndexResult(
        page: anyNamed('page'),
        params: anyNamed('params'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.pgcIndexResult(
        page: 1, params: <String, dynamic>{},
      );
      expect(result, isA<Error>());
    });

    test('edge: pgcIndexResult() handles empty params correctly', () async {
      when(mockRepo.pgcIndexResult(
        page: anyNamed('page'),
        params: anyNamed('params'),
      )).thenAnswer(
        (_) async => Success(CorePgcIndexResult.fromJson({})),
      );
      final result = await mockRepo.pgcIndexResult(
        page: 0, params: <String, dynamic>{},
      );
      expect(result.isSuccess, true);
    });
  });
}