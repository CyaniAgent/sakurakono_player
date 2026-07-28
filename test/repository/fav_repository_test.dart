import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'fav_repository_test.mocks.dart';

@GenerateMocks([FavRepository])

void main() {
  provideDummy<LoadingState<CoreFavDetailData>>(
    Success(CoreFavDetailData.fromJson({})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockFavRepository mockRepo;

  setUp(() {
    mockRepo = MockFavRepository();
  });

  group('FavRepository', () {
    test('happy: userFavFolderDetail() returns Success with data', () async {
      when(mockRepo.userFavFolderDetail(
        mediaId: anyNamed('mediaId'),
        pn: anyNamed('pn'),
        ps: anyNamed('ps'),
      )).thenAnswer(
        (_) async => Success(CoreFavDetailData.fromJson({})),
      );
      final result = await mockRepo.userFavFolderDetail(
        mediaId: 1, pn: 1, ps: 20,
      );
      expect(result, isA<Success<CoreFavDetailData>>());
    });

    test('error: userFavFolderDetail() returns Error', () async {
      when(mockRepo.userFavFolderDetail(
        mediaId: anyNamed('mediaId'),
        pn: anyNamed('pn'),
        ps: anyNamed('ps'),
      )).thenAnswer((_) async => const Error('网络错误'));
      final result = await mockRepo.userFavFolderDetail(
        mediaId: 1, pn: 1, ps: 20,
      );
      expect(result, isA<Error>());
    });

    test('edge: userFavFolderDetail() handles pn=0 correctly', () async {
      when(mockRepo.userFavFolderDetail(
        mediaId: anyNamed('mediaId'),
        pn: anyNamed('pn'),
        ps: anyNamed('ps'),
      )).thenAnswer(
        (_) async => Success(CoreFavDetailData.fromJson({})),
      );
      final result = await mockRepo.userFavFolderDetail(
        mediaId: 0, pn: 0, ps: 0,
      );
      expect(result.isSuccess, true);
    });
  });
}