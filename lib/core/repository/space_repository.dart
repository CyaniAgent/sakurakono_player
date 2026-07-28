import 'package:fixnum/fixnum.dart';
import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for space/opus data operations.
abstract class SpaceRepository {
  /// Get opus space flow for the given host.
  Future<LoadingState<CoreOpusSpaceFlowResp>> opusSpaceFlow({
    required int hostMid,
    String? next,
    required String filterType,
  });

  /// Search archives in a user's space.
  Future<LoadingState<CoreSearchArchiveReply>> searchArchive({
    required String keyword,
    required Int64 mid,
    required int pn,
    required Int64 ps,
  });
}
