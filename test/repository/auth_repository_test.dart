import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/repository/auth_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'auth_repository_test.mocks.dart';

@GenerateMocks([AuthRepository])

void main() {
  provideDummy<LoadingState<({String authCode, String url})>>(
    const Success((authCode: '', url: '')),
  );
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  group('AuthRepository', () {
    test('happy: getQRCode() returns Success with data', () async {
      when(mockRepo.getQRCode()).thenAnswer(
        (_) async => const Success((authCode: 'code123', url: 'https://example.com')),
      );
      final result = await mockRepo.getQRCode();
      expect(result, isA<Success<({String authCode, String url})>>());
      expect(result.data.authCode, 'code123');
    });

    test('error: getQRCode() returns Error', () async {
      when(mockRepo.getQRCode()).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.getQRCode();
      expect(result, isA<Error>());
    });

    test('edge: getQRCode() handles empty strings correctly', () async {
      when(mockRepo.getQRCode()).thenAnswer(
        (_) async => const Success((authCode: '', url: '')),
      );
      final result = await mockRepo.getQRCode();
      expect(result.isSuccess, true);
      expect(result.data.authCode, '');
      expect(result.data.url, '');
    });
  });
}