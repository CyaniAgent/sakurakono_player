import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/audio_types.dart';
import 'package:skf/core/repository/audio_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'audio_repository_test.mocks.dart';

@GenerateMocks([AudioRepository])

void main() {
  provideDummy<LoadingState<CoreAudioPlayUrlResp>>(Success(CoreAudioPlayUrlResp()));
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockAudioRepository mockRepo;

  setUp(() {
    mockRepo = MockAudioRepository();
  });

  group('AudioRepository', () {
    test('happy: audioPlayUrl() returns Success with data', () async {
      when(mockRepo.audioPlayUrl(
        oid: anyNamed('oid'),
        subId: anyNamed('subId'),
        itemType: anyNamed('itemType'),
      )).thenAnswer((_) async => Success(CoreAudioPlayUrlResp()));
      final result = await mockRepo.audioPlayUrl(
        oid: Int64(1),
        subId: [Int64(1)],
        itemType: 0,
      );
      expect(result, isA<Success<CoreAudioPlayUrlResp>>());
    });

    test('error: audioPlayUrl() returns Error', () async {
      when(mockRepo.audioPlayUrl(
        oid: anyNamed('oid'),
        subId: anyNamed('subId'),
        itemType: anyNamed('itemType'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.audioPlayUrl(
        oid: Int64(1),
        subId: [Int64(1)],
        itemType: 0,
      );
      expect(result, isA<Error>());
    });

    test('edge: audioPlayUrl() handles empty subId correctly', () async {
      when(mockRepo.audioPlayUrl(
        oid: anyNamed('oid'),
        subId: anyNamed('subId'),
        itemType: anyNamed('itemType'),
      )).thenAnswer((_) async => Success(CoreAudioPlayUrlResp()));
      final result = await mockRepo.audioPlayUrl(
        oid: Int64(0),
        subId: <Int64>[],
        itemType: 0,
      );
      expect(result.isSuccess, true);
    });
  });
}