import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Repository interface for reply (comment) operations.
///
/// Abstracts both gRPC and HTTP reply data sources. All data-fetching
/// methods return [LoadingState] for async results.
abstract class ReplyRepository {
  /// Get the main list of replies (comments) for a resource.
  Future<LoadingState<CoreMainListReply>> mainList({
    int type = 1,
    required int oid,
    required CoreMode mode,
    required String? offset,
    required int? cursorNext,
  });

  /// Get the detail list of sub-replies (reply-to-reply) for a root reply.
  Future<LoadingState<CoreDetailListReply>> detailList({
    int type = 1,
    required int oid,
    required int root,
    required int rpid,
    required CoreMode mode,
    required String? offset,
  });

  /// Get the dialog list (full threaded conversation).
  Future<LoadingState<CoreDialogListReply>> dialogList({
    int type = 1,
    required int oid,
    required int root,
    required int dialog,
    required String? offset,
  });

  /// Search within replies.
  Future<LoadingState<CoreSearchItemReply>> searchItem({
    required int page,
    required CoreSearchItemType itemType,
    required int oid,
    int type = 1,
    String? keyword,
  });

  /// Translate a reply's text content.
  Future<LoadingState<CoreTranslateReplyResp>> translateReply({
    required int type,
    required int oid,
    required int rpid,
  });

  /// Toggle a reply's top status.
  Future<LoadingState<void>> replyTop({
    required int oid,
    required int type,
    required Object rpid,
    required bool isUpTop,
  });

  /// Modify reply subject settings (e.g., close/open reply).
  Future<LoadingState<void>> replySubjectModify({
    required int oid,
    required int type,
    required int action,
  });
}
