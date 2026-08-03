import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/models/video_types.dart';
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

  /// Add a reply (comment).
  Future<LoadingState<CoreReplyInfo?>> replyAdd({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    List? pictures,
    bool syncToDynamic = false,
    Map<String, int>? atNameToMid,
  });

  /// Delete a reply (comment).
  Future<LoadingState<void>> replyDel({
    required int type,
    required int oid,
    required int rpid,
  });

  /// Like or unlike a reply.
  Future<LoadingState<void>> likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  });

  /// Hate or unhate a reply.
  Future<LoadingState<void>> hateReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  });

  /// Report a reply.
  Future<LoadingState<void>> report({
    required Object rpid,
    required Object oid,
    required int reasonType,
    bool banUid = true,
    String? reasonDesc,
  });

  // ---------------------------------------------------------------------------
  // Emote / sticker
  // ---------------------------------------------------------------------------

  /// Get emote/sticker package list.
  ///
  /// Returns adapter-specific data as [dynamic] since no core emote model exists
  /// yet. Callers should cast the response to the adapter's concrete type.
  Future<LoadingState<dynamic>> getEmoteList({String? business});
}
