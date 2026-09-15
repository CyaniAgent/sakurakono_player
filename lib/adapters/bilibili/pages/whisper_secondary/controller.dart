import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart'
    show Offset, Session, SessionPageType, SessionSecondaryReply, ThreeDotItem;
import 'package:skf/core/models/im_types.dart';
import 'package:skf/adapters/bilibili/grpc/im.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/adapters/bilibili/pages/common/common_whisper_controller.dart';
import 'package:protobuf/protobuf.dart' show PbMap;

CoreImSessionPageType _toCoreSessionPageType(SessionPageType type) {
  return switch (type) {
    SessionPageType.SESSION_PAGE_TYPE_HOME => CoreImSessionPageType.home,
    SessionPageType.SESSION_PAGE_TYPE_UNFOLLOWED =>
      CoreImSessionPageType.unfollowed,
    SessionPageType.SESSION_PAGE_TYPE_STRANGER =>
      CoreImSessionPageType.stranger,
    SessionPageType.SESSION_PAGE_TYPE_DUSTBIN => CoreImSessionPageType.dustbin,
    SessionPageType.SESSION_PAGE_TYPE_GROUP => CoreImSessionPageType.group,
    SessionPageType.SESSION_PAGE_TYPE_HUA_HUO => CoreImSessionPageType.huahuo,
    SessionPageType.SESSION_PAGE_TYPE_AI => CoreImSessionPageType.ai,
    SessionPageType.SESSION_PAGE_TYPE_CUSTOMER =>
      CoreImSessionPageType.customer,
    _ => CoreImSessionPageType.unknown,
  };
}

SessionPageType _toGrpcSessionPageType(CoreImSessionPageType type) {
  return switch (type) {
    CoreImSessionPageType.home => SessionPageType.SESSION_PAGE_TYPE_HOME,
    CoreImSessionPageType.unfollowed =>
      SessionPageType.SESSION_PAGE_TYPE_UNFOLLOWED,
    CoreImSessionPageType.stranger =>
      SessionPageType.SESSION_PAGE_TYPE_STRANGER,
    CoreImSessionPageType.dustbin => SessionPageType.SESSION_PAGE_TYPE_DUSTBIN,
    CoreImSessionPageType.group => SessionPageType.SESSION_PAGE_TYPE_GROUP,
    CoreImSessionPageType.huahuo => SessionPageType.SESSION_PAGE_TYPE_HUA_HUO,
    CoreImSessionPageType.ai => SessionPageType.SESSION_PAGE_TYPE_AI,
    CoreImSessionPageType.customer => SessionPageType.SESSION_PAGE_TYPE_CUSTOMER,
    _ => SessionPageType.SESSION_PAGE_TYPE_UNKNOWN,
  };
}

class WhisperSecController
    extends CommonWhisperController<SessionSecondaryReply> {
  WhisperSecController({
    required SessionPageType sessionPageType,
  }) : sessionPageType = _toCoreSessionPageType(sessionPageType) {
    queryData();
  }
  PbMap<int, Offset>? offset;
  @override
  final CoreImSessionPageType sessionPageType;
  List<ThreeDotItem>? threeDotItems;

  @override
  Future<void> onRefresh() {
    offset = null;
    return super.onRefresh();
  }

  @override
  List<Session>? getDataList(SessionSecondaryReply response) {
    if (!response.paginationParams.hasMore) {
      isEnd = true;
    }
    offset = response.paginationParams.offsets;

    return response.sessions;
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<SessionSecondaryReply> response,
  ) {
    if (isRefresh) {
      threeDotItems = response.response.threeDotItems;
      notifyListeners();
    }
    return false;
  }

  @override
  Future<LoadingState<SessionSecondaryReply>> customGetData() async {
    final result = await ImGrpc.sessionSecondary(
      offset: offset,
      pageType: _toGrpcSessionPageType(sessionPageType),
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}