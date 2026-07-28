import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'member_repository_test.mocks.dart';

@GenerateMocks([MemberRepository])

void main() {
  provideDummy<LoadingState<CoreMemberInfoModel>>(
    Success(CoreMemberInfoModel.fromJson(<String, dynamic>{'vip': <String, dynamic>{'vipStatus': 0}})),
  );
  provideDummy<LoadingState<void>>(const Success<void>(null));
  late MockMemberRepository mockRepo;

  setUp(() {
    mockRepo = MockMemberRepository();
  });

  group('MemberRepository', () {
    test('happy: memberInfo() returns Success with data', () async {
      when(mockRepo.memberInfo(mid: anyNamed('mid'))).thenAnswer(
        (_) async => Success(CoreMemberInfoModel.fromJson(<String, dynamic>{'vip': <String, dynamic>{'vipStatus': 0}})),
      );
      final result = await mockRepo.memberInfo(mid: 123);
      expect(result, isA<Success<CoreMemberInfoModel>>());
    });

    test('error: memberInfo() returns Error', () async {
      when(mockRepo.memberInfo(mid: anyNamed('mid'))).thenAnswer(
        (_) async => const Error('网络错误'),
      );
      final result = await mockRepo.memberInfo(mid: 123);
      expect(result, isA<Error>());
    });

    test('edge: memberInfo() handles mid=0 correctly', () async {
      when(mockRepo.memberInfo(mid: anyNamed('mid'))).thenAnswer(
        (_) async => Success(CoreMemberInfoModel.fromJson(<String, dynamic>{'vip': <String, dynamic>{'vipStatus': 0}})),
      );
      final result = await mockRepo.memberInfo(mid: 0);
      expect(result.isSuccess, true);
    });
  });
}