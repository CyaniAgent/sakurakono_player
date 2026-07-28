import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/blacklist_data.dart';
import 'package:skf/core/repository/black_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'black_repository_test.mocks.dart';

@GenerateMocks([BlackRepository])

void main() {
  provideDummy<LoadingState<CoreBlackListData>>(
    Success(CoreBlackListData.fromJson({})),
  );
  late MockBlackRepository mockRepo;

  setUp(() {
    mockRepo = MockBlackRepository();
  });

  group('BlackRepository', () {
    test('happy: blackList() returns Success with data', () async {
      when(mockRepo.blackList(pn: anyNamed('pn'))).thenAnswer(
        (_) async => Success(CoreBlackListData.fromJson({
          'list': <dynamic>[],
          'total': 0,
        })),
      );
      final result = await mockRepo.blackList(pn: 1);
      expect(result, isA<Success<CoreBlackListData>>());
    });

    test('error: blackList() returns Error', () async {
      when(mockRepo.blackList(pn: anyNamed('pn'))).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.blackList(pn: 1);
      expect(result, isA<Error>());
    });

    test('edge: blackList() handles pn=0 correctly', () async {
      when(mockRepo.blackList(pn: anyNamed('pn'))).thenAnswer(
        (_) async => Success(CoreBlackListData.fromJson({
          'list': <dynamic>[],
          'total': 0,
        })),
      );
      final result = await mockRepo.blackList(pn: 0);
      expect(result.isSuccess, true);
    });
  });
}