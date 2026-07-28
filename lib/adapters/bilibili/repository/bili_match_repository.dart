
import 'package:skf/adapters/bilibili/http/match.dart';
import 'package:skf/core/models/match_contest.dart';
import 'package:skf/core/repository/match_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [MatchRepository] that delegates to [MatchHttp].
class BiliMatchRepository implements MatchRepository {
  @override
  Future<LoadingState<CoreMatchContest?>> matchInfo(Object cid) async {
    final result = await MatchHttp.matchInfo(cid);
    if (result case Success(:final response)) {
      return Success(
        response != null
            ? CoreMatchContest.fromJson(response.toJson())
            : null,
      );
    }
    return result as LoadingState<CoreMatchContest?>;
  }
}