import 'package:flutter/material.dart';

import 'package:skf/adapters/ottohub/services/otto_member_pages.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/member/member_host.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/utils.dart';

/// OttoHub 用户页宿主实现。
///
/// 用户页头部数据(昵称/头像/粉丝数)经 Core MemberRepository
/// (OttoHub 实现);tab 内容:
/// - `contribute` 投稿 → [OttoMemberArchiveTab](/video/user/{uid} 网格)
/// - `dynamics` 动态 → [OttoMemberBlogTab](/blog/users/{uid}/blogs)
/// 关注/取关经 Core FollowRepository.toggleFollow(REST 路由已确认存活);
/// 其余 B站 专属交互(网页投稿/直播间勋章等)降级 no-op。
class OttoMemberHost implements MemberHost {

  @override
  int get currentUserId =>
      appRead(accountProvider).userId ?? -1;

  @override
  List<CoreSpaceTab2> filterTabs(List<CoreSpaceTab2> tabs) => tabs
      .where((t) => t.param == 'contribute' || t.param == 'dynamics')
      .toList();

  @override
  String? get preferredTabParam => 'contribute';

  @override
  Widget buildTab({
    required String param,
    String? title,
    required String heroTag,
    required int mid,
    required int contributeInitialIndex,
  }) {
    return switch (param) {
      'dynamics' => OttoMemberBlogTab(key: ValueKey('dyn-$mid'), mid: mid),
      'contribute' || 'home' || _ => OttoMemberArchiveTab(
          key: ValueKey('arc-$mid'),
          mid: mid,
        ),
    };
  }

  @override
  bool canToWebArchive(String heroTag) => false;

  @override
  void toWebArchive({
    required String heroTag,
    required int mid,
    required String username,
  }) {
  }

  @override
  Future<void> actionRelationMod(
    BuildContext context, {
    required int mid,
    required bool isFollow,
    required ValueChanged<int> afterMod,
  }) async {
    feedBack();
    final res = await appRead(followRepositoryProvider).toggleFollow(
      fid: mid,
    );
    if (res case Success()) {
      // OttoHub toggle 后无独立状态回包,按请求方向给出目标关系态。
      afterMod(isFollow ? 2 : 0);
    } else {
      res.toast();
    }
  }

  @override
  void shareUser(int mid) {
    Utils.copyText('https://www.ottohub.cn/user/$mid');
  }

  @override
  void pushDynFromId(String? id) {
    final bid = int.tryParse(id ?? '');
    if (bid != null) {
      AppNavigator.toNamed(
        '/blogDetail',
        parameters: {'bid': '$bid'},
      );
    }
  }

  @override
  void handleWebview(String url) {
    AppNavigator.toNamed(
      '/webview',
      parameters: {'url': url},
    );
  }

  @override
  void pushFromUri(String uri) {
    handleWebview(uri);
  }

}
