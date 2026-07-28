import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'video_repository_test.mocks.dart';

@GenerateMocks([VideoRepository])

void main() {
  provideDummy<LoadingState<CoreVideoDetailData>>(
    Success(CoreVideoDetailData.fromJson({})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockVideoRepository mockRepo;

  setUp(() {
    mockRepo = MockVideoRepository();
  });

  group('VideoRepository', () {
    test('happy: videoIntro() returns Success with data', () async {
      when(mockRepo.videoIntro(bvid: anyNamed('bvid'))).thenAnswer(
        (_) async => Success(CoreVideoDetailData.fromJson({})),
      );
      final result = await mockRepo.videoIntro(bvid: 'BV1xx');
      expect(result, isA<Success<CoreVideoDetailData>>());
    });

    test('error: videoIntro() returns Error', () async {
      when(mockRepo.videoIntro(bvid: anyNamed('bvid'))).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.videoIntro(bvid: 'BV1xx');
      expect(result, isA<Error>());
    });

    test('edge: videoIntro() handles empty bvid correctly', () async {
      when(mockRepo.videoIntro(bvid: anyNamed('bvid'))).thenAnswer(
        (_) async => Success(CoreVideoDetailData.fromJson({})),
      );
      final result = await mockRepo.videoIntro(bvid: '');
      expect(result.isSuccess, true);
    });
  });
}