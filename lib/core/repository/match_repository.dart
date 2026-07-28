import 'package:skf/core/models/match_contest.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for match/contest data operations.
abstract class MatchRepository {
  /// Get match/contest info for the given contest ID.
  Future<LoadingState<CoreMatchContest?>> matchInfo(Object cid);
}
