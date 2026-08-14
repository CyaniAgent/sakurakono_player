import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'download_repository_test.mocks.dart';

@GenerateMocks([DownloadRepository])

void main() {
  provideDummy<LoadingState<CoreDownloadMediaInfo>>(
    Success(CoreType2(video: <CoreType2File>[])),
  );
  provideDummy<LoadingState<List<CoreDownloadEntryInfo>>>(
    const Success(<CoreDownloadEntryInfo>[]),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockDownloadRepository mockRepo;

  setUp(() {
    mockRepo = MockDownloadRepository();
  });

  group('DownloadRepository', () {
    test('happy: getVideoUrl() returns Success with data', () async {
      when(mockRepo.getVideoUrl(
        entry: anyNamed('entry'),
      )).thenAnswer((_) async => Success(CoreType2(video: <CoreType2File>[])));
      final entry = CoreDownloadEntryInfo(
        isCompleted: false,
        totalBytes: 0,
        downloadedBytes: 0,
        title: 'test',
        cover: '',
        preferedVideoQuality: 0,
        guessedTotalBytes: 0,
        totalTimeMilli: 0,
        danmakuCount: 0,
        avid: 1,
        bvid: 'BV1',
      );
      final result = await mockRepo.getVideoUrl(entry: entry);
      expect(result, isA<Success<CoreDownloadMediaInfo>>());
    });

    test('error: getVideoUrl() returns Error', () async {
      when(mockRepo.getVideoUrl(
        entry: anyNamed('entry'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final entry = CoreDownloadEntryInfo(
        isCompleted: false,
        totalBytes: 0,
        downloadedBytes: 0,
        title: 'test',
        cover: '',
        preferedVideoQuality: 0,
        guessedTotalBytes: 0,
        totalTimeMilli: 0,
        danmakuCount: 0,
        avid: 1,
        bvid: 'BV1',
      );
      final result = await mockRepo.getVideoUrl(entry: entry);
      expect(result, isA<Error>());
    });

    test('edge: getVideoUrl() handles null source correctly', () async {
      when(mockRepo.getVideoUrl(
        entry: anyNamed('entry'),
      )).thenAnswer((_) async => Success(CoreType2(video: <CoreType2File>[])));
      final entry = CoreDownloadEntryInfo(
        isCompleted: false,
        totalBytes: 0,
        downloadedBytes: 0,
        title: 'test',
        cover: '',
        preferedVideoQuality: 0,
        guessedTotalBytes: 0,
        totalTimeMilli: 0,
        danmakuCount: 0,
        avid: 1,
        bvid: 'BV1',
      );
      final result = await mockRepo.getVideoUrl(entry: entry);
      expect(result.isSuccess, true);
    });
  });
}