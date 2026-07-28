import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/music_types.dart';
import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'music_repository_test.mocks.dart';

@GenerateMocks([MusicRepository])

void main() {
  provideDummy<LoadingState<CoreMusicDetail>>(
    Success(CoreMusicDetail(
      musicTitle: null,
      originArtist: null,
      originArtistList: null,
      mvAid: null,
      mvCid: 0,
      mvBvid: null,
      mvCover: null,
      wishListen: false,
      wishCount: 0,
      musicSource: null,
      album: null,
      artistsList: null,
      listenPv: 0,
      achievement: <String>[],
      hotSongHeat: null,
      musicComment: null,
      musicRelation: null,
      musicPublish: null,
    )),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockMusicRepository mockRepo;

  setUp(() {
    mockRepo = MockMusicRepository();
  });

  group('MusicRepository', () {
    test('happy: bgmDetail() returns Success with data', () async {
      when(mockRepo.bgmDetail(any)).thenAnswer(
        (_) async => Success(CoreMusicDetail(
          musicTitle: 'test',
          originArtist: 'artist',
          originArtistList: null,
          mvAid: 1,
          mvCid: 1,
          mvBvid: 'BV1',
          mvCover: 'cover',
          wishListen: false,
          wishCount: 0,
          musicSource: null,
          album: null,
          artistsList: null,
          listenPv: 0,
          achievement: <String>[],
          hotSongHeat: null,
          musicComment: null,
          musicRelation: null,
          musicPublish: null,
        )),
      );
      final result = await mockRepo.bgmDetail('music1');
      expect(result, isA<Success<CoreMusicDetail>>());
      expect(result.data.musicTitle, 'test');
    });

    test('error: bgmDetail() returns Error', () async {
      when(mockRepo.bgmDetail(any)).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.bgmDetail('music1');
      expect(result, isA<Error>());
    });

    test('edge: bgmDetail() handles empty musicId correctly', () async {
      when(mockRepo.bgmDetail(any)).thenAnswer(
        (_) async => Success(CoreMusicDetail(
          musicTitle: null,
          originArtist: null,
          originArtistList: null,
          mvAid: null,
          mvCid: 0,
          mvBvid: null,
          mvCover: null,
          wishListen: false,
          wishCount: 0,
          musicSource: null,
          album: null,
          artistsList: null,
          listenPv: 0,
          achievement: <String>[],
          hotSongHeat: null,
          musicComment: null,
          musicRelation: null,
          musicPublish: null,
        )),
      );
      final result = await mockRepo.bgmDetail('');
      expect(result.isSuccess, true);
    });
  });
}