import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/adapters/bilibili/common/widgets/dialog/report_member.dart';
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:flutter/widgets.dart' show BuildContext, Text;

class WhisperLinkSettingState {
  WhisperLinkSettingState({
    LoadingState<List<CoreImUserInfosData>?>? userState,
    LoadingState<CoreSessionSsData>? sessionSs,
    LoadingState<List<CoreUidSetting>?>? msgDnd,
    this.isPinned = false,
  })  : userState = userState ?? LoadingState<List<CoreImUserInfosData>?>.loading(),
        sessionSs = sessionSs ?? LoadingState<CoreSessionSsData>.loading(),
        msgDnd = msgDnd ?? LoadingState<List<CoreUidSetting>?>.loading();

  final LoadingState<List<CoreImUserInfosData>?> userState;
  final LoadingState<CoreSessionSsData> sessionSs;
  final LoadingState<List<CoreUidSetting>?> msgDnd;
  final bool isPinned;

  WhisperLinkSettingState copyWith({
    LoadingState<List<CoreImUserInfosData>?>? userState,
    LoadingState<CoreSessionSsData>? sessionSs,
    LoadingState<List<CoreUidSetting>?>? msgDnd,
    bool? isPinned,
  }) {
    return WhisperLinkSettingState(
      userState: userState ?? this.userState,
      sessionSs: sessionSs ?? this.sessionSs,
      msgDnd: msgDnd ?? this.msgDnd,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class WhisperLinkSettingNotifier extends StateNotifier<WhisperLinkSettingState> {
  WhisperLinkSettingNotifier({
    required this.talkerUid,
    required this._msgRepository,
    required this._imRepository,
    required this._videoRepository,
  })  : sessionId = CoreImSessionId(privateTalkerUid: talkerUid),
       super(WhisperLinkSettingState()) {
    getUserInfo();
    getSessionSs();
    getMsgDnd();
    getIsPinned();
  }

  final int talkerUid;
  final MsgRepository _msgRepository;
  final ImRepository _imRepository;
  final VideoRepository _videoRepository;
  final CoreImSessionId sessionId;

  Future<void> getUserInfo() async {
    final result = await _msgRepository.imUserInfos(uids: talkerUid.toString());
    state = state.copyWith(
      userState: switch (result) {
        Loading() => LoadingState<List<CoreImUserInfosData>?>.loading(),
        Success(:final response) => Success(response),
        Error(:final errMsg) => Error(errMsg),
      },
    );
  }

  Future<void> getSessionSs() async {
    final result = await _msgRepository.getSessionSs(talkerUid: talkerUid);
    state = state.copyWith(
      sessionSs: switch (result) {
        Loading() => LoadingState<CoreSessionSsData>.loading(),
        Success(:final response) => Success(response),
        Error(:final errMsg) => Error(errMsg),
      },
    );
  }

  Future<void> getMsgDnd() async {
    final result = await _msgRepository.getMsgDnd(uidsStr: talkerUid.toString());
    state = state.copyWith(
      msgDnd: switch (result) {
        Loading() => LoadingState<List<CoreUidSetting>?>.loading(),
        Success(:final response) => Success(response),
        Error(:final errMsg) => Error(errMsg),
      },
    );
  }

  Future<void> getIsPinned() async {
    final res = await _imRepository.sessionUpdate(sessionId: sessionId);
    if (res case Success(:final response)) {
      state = state.copyWith(isPinned: response.session?.isPinned ?? false);
    }
  }

  void setPush(BuildContext context, bool isPush) {
    if (isPush) {
      showConfirmDialog(
        context: context,
        title: const Text('确认关闭内容推送吗？'),
        content: const Text('若关闭此开关，你将不再收到该账号的图文消息与稿件推送，但通知类消息不受影响'),
        onConfirm: () => _setPush(isPush),
      );
      return;
    }
    _setPush(isPush);
  }

  Future<void> _setPush(bool isPush) async {
    final int setting = isPush ? 1 : 0;
    final res = await _msgRepository.setPushSs(
      setting: setting,
      talkerUid: talkerUid,
    );
    if (res.isSuccess) {
      final current = state.sessionSs;
      if (current case Success(:final response)) {
        response.pushSetting = setting;
        state = state.copyWith(sessionSs: Success(response));
      }
    } else {
      res.toast();
    }
  }

  Future<void> setPin() async {
    final res = state.isPinned
        ? await _imRepository.unpinSession(sessionId: sessionId)
        : await _imRepository.pinSession(sessionId: sessionId);
    if (res.isSuccess) {
      state = state.copyWith(isPinned: !state.isPinned);
    } else {
      res.toast();
    }
  }

  Future<void> setMute(bool isMuted) async {
    final int setting = isMuted ? 0 : 1;
    final res = await _msgRepository.setMsgDnd(
      uid: Accounts.main.mid,
      setting: setting,
      dndUid: talkerUid,
    );
    if (res.isSuccess) {
      final current = state.msgDnd;
      if (current case Success(:final response) when response != null && response.isNotEmpty) {
        response.first.setting = setting;
        state = state.copyWith(msgDnd: Success(response));
      }
    } else {
      res.toast();
    }
  }

  Future<void> setBlock(BuildContext context, bool isBlocked) async {
    if (isBlocked) {
      final res = await _videoRepository.relationMod(
        mid: talkerUid,
        act: 6,
        reSrc: 11,
      );
      if (res.isSuccess) {
        final current = state.sessionSs;
        if (current case Success(:final response)) {
          response.followStatus = null;
          state = state.copyWith(sessionSs: Success(response));
        }
      } else {
        res.toast();
      }
    } else {
      showConfirmDialog(
        context: context,
        title: const Text('确认拉黑该用户'),
        content: const Text('加入黑名单后，将自动解除关注关系和对该用户的合集订阅关系，禁止该用户与我互动或查看我的空间'),
        onConfirm: () async {
          final res = await _videoRepository.relationMod(
            mid: talkerUid,
            act: 5,
            reSrc: 11,
          );
          if (res.isSuccess) {
            final current = state.sessionSs;
            if (current case Success(:final response)) {
              response.followStatus = 128;
              state = state.copyWith(sessionSs: Success(response));
            }
          } else {
            res.toast();
          }
        },
      );
    }
  }

  void report(BuildContext context) => showMemberReportDialog(
    context,
    name: state.userState.dataOrNull?.firstOrNull?.name,
    mid: talkerUid,
  );
}

final whisperLinkSettingProvider = StateNotifierProvider.autoDispose.family<
    WhisperLinkSettingNotifier,
    WhisperLinkSettingState,
    int>((ref, talkerUid) {
  return WhisperLinkSettingNotifier(
    talkerUid: talkerUid,
    msgRepository: ref.read(msgRepositoryProvider),
    imRepository: ref.read(imRepositoryProvider),
    videoRepository: ref.read(videoRepositoryProvider),
  );
});
