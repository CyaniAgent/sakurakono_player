import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/core/models/match_contest.dart';
import 'package:skf/core/repository/match_repository.dart';
import 'package:skf/core/result/loading_state.dart';

// impossible — no SDK API (OttoHub 无此域)
/// Stub [MatchRepository] — OttoHub SDK has no match/contest API.
class OttoMatchRepository implements MatchRepository {
  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<LoadingState<CoreMatchContest?>> matchInfo(Object cid) async =>
      _err(const ApiException('not_implemented'));
}