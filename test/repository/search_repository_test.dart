import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'search_repository_test.mocks.dart';

@GenerateMocks([SearchRepository])

void main() {
  provideDummy<LoadingState<CoreSearchSuggestModel>>(
    Success(CoreSearchSuggestModel.fromJson({})),
  );
  late MockSearchRepository mockRepo;

  setUp(() {
    mockRepo = MockSearchRepository();
  });

  group('SearchRepository', () {
    test('happy: searchSuggest() returns Success with data', () async {
      when(mockRepo.searchSuggest(term: anyNamed('term'))).thenAnswer(
        (_) async => Success(CoreSearchSuggestModel.fromJson({})),
      );
      final result = await mockRepo.searchSuggest(term: 'test');
      expect(result, isA<Success<CoreSearchSuggestModel>>());
    });

    test('error: searchSuggest() returns Error', () async {
      when(mockRepo.searchSuggest(term: anyNamed('term'))).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.searchSuggest(term: 'test');
      expect(result, isA<Error>());
    });

    test('edge: searchSuggest() handles empty term correctly', () async {
      when(mockRepo.searchSuggest(term: anyNamed('term'))).thenAnswer(
        (_) async => Success(CoreSearchSuggestModel.fromJson({})),
      );
      final result = await mockRepo.searchSuggest(term: '');
      expect(result.isSuccess, true);
    });
  });
}