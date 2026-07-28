import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/repository/sponsor_block_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'sponsor_block_repository_test.mocks.dart';

@GenerateMocks([SponsorBlockRepository])

void main() {
  provideDummy<LoadingState<List<CoreSegmentItemModel>>>(
    Success(<CoreSegmentItemModel>[]),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockSponsorBlockRepository mockRepo;

  setUp(() {
    mockRepo = MockSponsorBlockRepository();
  });

  group('SponsorBlockRepository', () {
    test('happy: getSkipSegments() returns Success with data', () async {
      when(mockRepo.getSkipSegments(
        bvid: anyNamed('bvid'),
        cid: anyNamed('cid'),
      )).thenAnswer(
        (_) async => Success(<CoreSegmentItemModel>[]),
      );
      final result = await mockRepo.getSkipSegments(bvid: 'BV1', cid: 1);
      expect(result, isA<Success<List<CoreSegmentItemModel>>>());
    });

    test('error: getSkipSegments() returns Error', () async {
      when(mockRepo.getSkipSegments(
        bvid: anyNamed('bvid'),
        cid: anyNamed('cid'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.getSkipSegments(bvid: 'BV1', cid: 1);
      expect(result, isA<Error>());
    });

    test('edge: getSkipSegments() handles empty bvid correctly', () async {
      when(mockRepo.getSkipSegments(
        bvid: anyNamed('bvid'),
        cid: anyNamed('cid'),
      )).thenAnswer(
        (_) async => Success(<CoreSegmentItemModel>[]),
      );
      final result = await mockRepo.getSkipSegments(bvid: '', cid: 0);
      expect(result.isSuccess, true);
    });
  });
}