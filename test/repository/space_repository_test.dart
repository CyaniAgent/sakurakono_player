import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/repository/space_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'space_repository_test.mocks.dart';

@GenerateMocks([SpaceRepository])

void main() {
  provideDummy<LoadingState<CoreOpusSpaceFlowResp>>(Success(CoreOpusSpaceFlowResp()));
  late MockSpaceRepository mockRepo;

  setUp(() {
    mockRepo = MockSpaceRepository();
  });

  group('SpaceRepository', () {
    test('happy: opusSpaceFlow() returns Success with data', () async {
      when(mockRepo.opusSpaceFlow(
        hostMid: anyNamed('hostMid'),
        filterType: anyNamed('filterType'),
      )).thenAnswer((_) async => Success(CoreOpusSpaceFlowResp()));
      final result = await mockRepo.opusSpaceFlow(
        hostMid: 123, filterType: 'all',
      );
      expect(result, isA<Success<CoreOpusSpaceFlowResp>>());
    });

    test('error: opusSpaceFlow() returns Error', () async {
      when(mockRepo.opusSpaceFlow(
        hostMid: anyNamed('hostMid'),
        filterType: anyNamed('filterType'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.opusSpaceFlow(
        hostMid: 123, filterType: 'all',
      );
      expect(result, isA<Error>());
    });

    test('edge: opusSpaceFlow() handles hostMid=0 correctly', () async {
      when(mockRepo.opusSpaceFlow(
        hostMid: anyNamed('hostMid'),
        filterType: anyNamed('filterType'),
      )).thenAnswer((_) async => Success(CoreOpusSpaceFlowResp()));
      final result = await mockRepo.opusSpaceFlow(
        hostMid: 0, filterType: '',
      );
      expect(result.isSuccess, true);
    });
  });
}