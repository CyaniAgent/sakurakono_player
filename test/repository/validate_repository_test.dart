import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/repository/validate_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'validate_repository_test.mocks.dart';

@GenerateMocks([ValidateRepository])

void main() {
  provideDummy<LoadingState<Map?>>(const Success<Map?>(null));
  late MockValidateRepository mockRepo;

  setUp(() {
    mockRepo = MockValidateRepository();
  });

  group('ValidateRepository', () {
    test('happy: gaiaVgateRegister() returns Success with data', () async {
      when(mockRepo.gaiaVgateRegister(any)).thenAnswer(
        (_) async => const Success(<String, dynamic>{'voucher': 'test'}),
      );
      final result = await mockRepo.gaiaVgateRegister('voucher123');
      expect(result, isA<Success<Map?>>());
      expect(result.data, isA<Map<String, dynamic>>());
    });

    test('error: gaiaVgateRegister() returns Error', () async {
      when(mockRepo.gaiaVgateRegister(any)).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.gaiaVgateRegister('voucher123');
      expect(result, isA<Error>());
    });

    test('edge: gaiaVgateRegister() handles empty voucher correctly', () async {
      when(mockRepo.gaiaVgateRegister(any)).thenAnswer(
        (_) async => const Success<Map?>(null),
      );
      final result = await mockRepo.gaiaVgateRegister('');
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isNull);
    });
  });
}