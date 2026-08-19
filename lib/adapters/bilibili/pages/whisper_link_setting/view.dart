import 'package:skf/common/widgets/pendant_avatar.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/msg_types.dart';

import 'package:skf/adapters/bilibili/pages/whisper_link_setting/controller.dart';
import 'package:skf/adapters/bilibili/utils/extension/theme_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhisperLinkSettingPage extends ConsumerWidget {
  const WhisperLinkSettingPage({
    super.key,
    required this.talkerUid,
  });

  final int talkerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(whisperLinkSettingProvider(talkerUid));
    final notifier = ref.read(whisperLinkSettingProvider(talkerUid).notifier);
    final ThemeData theme = Theme.of(context);
    final divider = Divider(
      height: 12,
      thickness: 12,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
    final divider2 = Divider(
      height: 1,
      indent: 16,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('聊天设置')),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
        ),
        children: [
          divider,
          _buildUserInfo(theme, divider, state.userState, notifier, context),
          _buildSessionSs(
            theme,
            divider,
            divider2,
            state.sessionSs,
            state,
            notifier,
            context,
          ),
          if (state.sessionSs case Success(:final response))
            _buildBlockItem(response.followStatus == 128, notifier, context)
          else
            const SizedBox.shrink(),
          divider2,
          ListTile(
            dense: true,
            onTap: () => notifier.report(context),
            title: const Text('举报', style: TextStyle(fontSize: 14)),
            trailing: Icon(
              Icons.keyboard_arrow_right,
              color: theme.colorScheme.outline,
            ),
          ),
          divider,
        ],
      ),
    );
  }

  Widget _buildBlockItem(
    bool isBlocked,
    WhisperLinkSettingNotifier notifier,
    BuildContext context,
  ) {
    return ListTile(
      dense: true,
      onTap: () => notifier.setBlock(context, isBlocked),
      title: const Text('加入黑名单', style: TextStyle(fontSize: 14)),
      trailing: Transform.scale(
        alignment: Alignment.centerRight,
        scale: 0.8,
        child: Switch(
          value: isBlocked,
          onChanged: (value) => notifier.setBlock(context, isBlocked),
        ),
      ),
    );
  }

  Widget _buildUserInfo(
    ThemeData theme,
    Widget divider,
    LoadingState<List<CoreImUserInfosData>?> loadingState,
    WhisperLinkSettingNotifier notifier,
    BuildContext context,
  ) {
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final CoreImUserInfosData item = response.first;
                      return ListTile(
                        onTap: () => Navigator.of(context).pushNamed(
                          '/member?mid=${item.mid}',
                        ),
                        leading: PendantAvatar(
                          item.face,
                          size: 42,
                          badgeSize: 14,
                          vipStatus: item.vip?.status,
                          pendantImage: item.pendant?.image,
                          officialType: item.official?.type,
                        ),
                        title: Text(
                          item.name!,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                item.vip?.status != null &&
                                    item.vip!.status > 0 &&
                                    item.vip?.type == 2
                                ? theme.colorScheme.vipColor
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          'UID: ${item.mid}${item.sign?.isNotEmpty == true ? '\n${item.sign}' : ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        trailing: Icon(
                          size: 22,
                          Icons.keyboard_arrow_right,
                          color: theme.colorScheme.outline,
                        ),
                      );
                    },
                  ),
                  divider,
                ],
              )
            : const SizedBox.shrink(),
      Error(:final errMsg) => _errWidget(errMsg, notifier.getUserInfo),
    };
  }

  Widget _buildSessionSs(
    ThemeData theme,
    Widget divider,
    Widget divider2,
    LoadingState<CoreSessionSsData> loadingState,
    WhisperLinkSettingState state,
    WhisperLinkSettingNotifier notifier,
    BuildContext context,
  ) {
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) => Builder(
        builder: (context) {
          late final subTitleS = TextStyle(
            fontSize: 13,
            color: theme.colorScheme.outline,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (response.showPushSetting == 1)
                ListTile(
                  dense: true,
                  onTap: () =>
                      notifier.setPush(context, response.pushSetting == 0),
                  title: const Text('接收消息推送', style: TextStyle(fontSize: 14)),
                  subtitle: Text(
                    '若关闭此开关，你将不再收到该账号的图文消息与稿件推送，但通知类消息不受影响',
                    style: subTitleS,
                  ),
                  trailing: Transform.scale(
                    alignment: Alignment.centerRight,
                    scale: 0.8,
                    child: Switch(
                      value: response.pushSetting == 0,
                      onChanged: (value) =>
                          notifier.setPush(context, response.pushSetting == 0),
                    ),
                  ),
                ),
              divider2,
              ListTile(
                dense: true,
                onTap: notifier.setPin,
                title: const Text('置顶聊天', style: TextStyle(fontSize: 14)),
                trailing: Transform.scale(
                  alignment: Alignment.centerRight,
                  scale: 0.8,
                  child: Switch(
                    value: state.isPinned,
                    onChanged: (value) => notifier.setPin(),
                  ),
                ),
              ),
              divider2,
              _buildMuteItem(state.msgDnd, notifier),
              divider,
            ],
          );
        },
      ),
      Error(:final errMsg) => _errWidget(errMsg, notifier.getSessionSs),
    };
  }

  Widget _buildMuteItem(
    LoadingState<List<CoreUidSetting>?> loadingState,
    WhisperLinkSettingNotifier notifier,
  ) {
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? ListTile(
                dense: true,
                onTap: () => notifier.setMute(response.first.setting == 1),
                title: const Text('消息免打扰', style: TextStyle(fontSize: 14)),
                trailing: Transform.scale(
                  alignment: Alignment.centerRight,
                  scale: 0.8,
                  child: Switch(
                    value: response.first.setting == 1,
                    onChanged: (value) =>
                        notifier.setMute(response.first.setting == 1),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      Error(:final errMsg) => _errWidget(errMsg, notifier.getMsgDnd),
    };
  }

  Widget _errWidget(String? errMsg, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          errMsg ?? '',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
