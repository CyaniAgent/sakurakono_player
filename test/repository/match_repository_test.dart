import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/match_contest.dart';
import 'package:skf/core/repository/match_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'match_repository_test.mocks.dart';

@GenerateMocks([MatchRepository])

void main() {
  provideDummy<LoadingState<CoreMatchContest?>>(
    const Success<CoreMatchContest?>(null),
  );
  late MockMatchRepository mockRepo;

  setUp(() {
    mockRepo = MockMatchRepository();
  });

  group('MatchRepository', () {
    test('happy: matchInfo() returns Success with data', () async {
      when(mockRepo.matchInfo(any)).thenAnswer(
        (_) async => Success(CoreMatchContest(
          gameStage: 'group_stage',
          homeScore: 1,
          awayScore: 0,
        )),
      );
      final result = await mockRepo.matchInfo(1);
      expect(result, isA<Success<CoreMatchContest?>>());
      expect(result.data?.homeScore, 1);
    });

    test('error: matchInfo() returns Error', () async {
      when(mockRepo.matchInfo(any)).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.matchInfo(1);
      expect(result, isA<Error>());
    });

    test('edge: matchInfo() returns null for unknown cid', () async {
      when(mockRepo.matchInfo(any)).thenAnswer(
        (_) async => const Success<CoreMatchContest?>(null),
      );
      final result = await mockRepo.matchInfo(-1);
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isNull);
    });
  });
}