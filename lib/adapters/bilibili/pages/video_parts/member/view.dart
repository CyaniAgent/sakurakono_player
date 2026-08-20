import 'package:skf/common/skeleton/video_card_h.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/common/widgets/sliver/sliver_pinned_header.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/ui/image_preview_type.dart';
import 'package:skf/core/models/ui/image_type.dart';
import 'package:skf/pages/member/widget/user_info_type.dart';

import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/episode.dart';
import 'package:skf/pages/fan/view.dart';
import 'package:skf/pages/follow/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video/widgets/video_card_h_member_video.dart';
import 'package:skf/pages/video/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/introduction/ugc/controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/member/controller.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/bili_utils.dart';
import 'package:skf/adapters/bilibili/utils/extension/theme_ext.dart';
import 'package:skf/utils/num_utils.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:skf/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class HorizontalMemberPage extends StatefulWidget {
  const HorizontalMemberPage({
    super.key,
    required this.mid,
    required this.videoDetailController,
    required this.ugcIntroController,
  });

  final dynamic mid;
  final VideoDetailController videoDetailController;
  final UgcIntroController ugcIntroController;

  @override
  State<HorizontalMemberPage> createState() => _HorizontalMemberPageState();
}

class _HorizontalMemberPageState extends State<HorizontalMemberPage> {
  late final HorizontalMemberPageController _controller;
  late final account = Accounts.main;
  late final String _bvid;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      HorizontalMemberPageController(
        mid: widget.mid,
        currAid: widget.videoDetailController.aid.toString(),
      ),
      tag: widget.videoDetailController.heroTag,
    );
    _bvid = widget.videoDetailController.bvid;
    if (_controller.loadingState.value
        case Success<List<CoreSpaceArchiveItem>?> res) {
      final index = res.response?.indexWhere((e) => e.bvid == _bvid) ?? -1;
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.scrollController.jumpTo(112.0 * index);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(
      () => _buildUserPage(theme, _controller.userState.value),
    );
  }

  Widget _buildUserPage(ThemeData theme, LoadingState userState) {
    return switch (userState) {
      Loading() => m3eLoading,
      Success(:final response) => Column(
        children: [
          _buildUserInfo(theme, response),
          Expanded(
            child: refreshIndicator(
              onRefresh: _controller.onRefresh,
              child: CustomScrollView(
                controller: _controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
                    ),
                    sliver: Obx(
                      () => _buildVideoList(
                        theme,
                        _controller.loadingState.value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      Error(:final errMsg) => scrollErrorWidget(
        controller: _controller.scrollController,
        errMsg: errMsg,
        onReload: () {
          _controller.userState.value = LoadingState<CoreMemberInfoModel>.loading();
          _controller.getUserInfo();
        },
      ),
    };
  }

  Widget _buildHeader(ThemeData theme) {
    return SliverPinnedHeader(
      backgroundColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 6, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ?_buildCount(),
            _buildSortBtn(theme),
          ],
        ),
      ),
    );
  }

  Widget? _buildCount() {
    final count = _controller.count;
    if (count != null) {
      return Text(
        '共$count视频',
        style: const TextStyle(fontSize: 13),
      );
    }
    return null;
  }

  Widget _buildSortBtn(ThemeData theme) {
    return TextButton.icon(
      style: Style.buttonStyle,
      onPressed: () => _controller
        ..lastAid = widget.videoDetailController.aid.toString()
        ..queryBySort(),
      icon: Icon(
        Icons.sort,
        size: 16,
        color: theme.colorScheme.secondary,
      ),
      label: Text(
        _controller.order.label,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildVideoList(
    ThemeData theme,
    LoadingState<List<CoreSpaceArchiveItem>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => SliverFixedExtentList.builder(
        itemCount: 10,
        itemBuilder: (_, _) => const VideoCardHSkeleton(),
        itemExtent: 112,
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverMainAxisGroup(
                slivers: [
                  _buildHeader(theme),
                  SliverFixedExtentList.builder(
                    itemBuilder: (context, index) {
                      if (index == response.length - 1 && _controller.hasNext) {
                        _controller.onLoadMore();
                      }
                      final videoItem = response[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: VideoCardHMemberVideo(
                          videoItem: ModelConverters.spaceArchiveItem(videoItem),
                          bvid: _bvid,
                          onTap: () {
                            AppNavigator.back();
                            widget.ugcIntroController.onChangeEpisode(
                              BaseEpisodeItem(
                                bvid: videoItem.bvid,
                                cid: videoItem.cid,
                                cover: videoItem.cover,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    itemCount: response.length,
                    itemExtent: 112,
                  ),
                ],
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  Widget _buildUserInfo(ThemeData theme, CoreMemberInfoModel coreMemberInfoModel) {
    return Padding(
      padding: const .only(left: 16, top: 10, right: 16, bottom: 3),
      child: Row(
        spacing: 10,
        children: [
          _buildAvatar(coreMemberInfoModel.face!),
          Expanded(child: _buildInfo(theme, coreMemberInfoModel)),
        ],
      ),
    );
  }

  Column _buildInfo(ThemeData theme, CoreMemberInfoModel coreMemberInfoModel) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          GestureDetector(
            onTap: () => Utils.copyText(coreMemberInfoModel.name ?? ''),
            child: Text(
              coreMemberInfoModel.name ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    (coreMemberInfoModel.coreVip?.status ?? -1) > 0 &&
                        coreMemberInfoModel.coreVip?.type == 2
                    ? theme.colorScheme.vipColor
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          BiliUtils.levelPicture(
            coreMemberInfoModel.level!,
            isSeniorMember: coreMemberInfoModel.isSeniorMember == 1,
            height: 11,
          ),
        ],
      ),
      const SizedBox(height: 4),
      Obx(
        () => Row(
          children: UserInfoType.values
              .map(
                (e) => _buildChildInfo(
                  theme: theme,
                  type: e,
                  userStat: _controller.userStat,
                  coreMemberInfoModel: coreMemberInfoModel,
                ),
              )
              .expand((child) sync* {
                yield SizedBox(
                  height: 10,
                  width: 20,
                  child: VerticalDivider(
                    width: 1,
                    color: theme.colorScheme.outline,
                  ),
                );
                yield child;
              })
              .skip(1)
              .toList(),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        spacing: 8,
        children: [
          Expanded(
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: coreMemberInfoModel.isFollowed == true
                    ? theme.colorScheme.onInverseSurface
                    : null,
                foregroundColor: coreMemberInfoModel.isFollowed == true
                    ? theme.colorScheme.outline
                    : null,
                padding: EdgeInsets.zero,
                tapTargetSize: .shrinkWrap,
                visualDensity: const VisualDensity(vertical: -2),
              ),
              onPressed: () {
                if (widget.mid == account.mid) {
                  AppNavigator.toNamed('/editProfile');
                } else {
                  if (!account.isLogin) {
                    SmartDialog.showToast('账号未登录');
                    return;
                  }
                  RequestUtils.actionRelationMod(
                    context: context,
                    mid: widget.mid,
                    isFollow: coreMemberInfoModel.isFollowed ?? false,
                    afterMod: (attribute) {
                      _controller
                        ..userState.value.data.isFollowed = attribute != 0
                        ..userState.refresh();
                    },
                  );
                }
              },
              child: Text(
                widget.mid == account.mid
                    ? '编辑资料'
                    : coreMemberInfoModel.isFollowed == true
                    ? '已关注'
                    : '关注',
                maxLines: 1,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: .shrinkWrap,
                visualDensity: const VisualDensity(vertical: -2),
              ),
              onPressed: () => AppNavigator.toNamed('/member?mid=${widget.mid}'),
              child: const Text(
                '查看主页',
                maxLines: 1,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildChildInfo({
    required ThemeData theme,
    required UserInfoType type,
    required Map userStat,
    required CoreMemberInfoModel coreMemberInfoModel,
  }) {
    dynamic num;
    VoidCallback? onTap;
    switch (type) {
      case UserInfoType.fan:
        num = userStat['follower'] != null
            ? NumUtils.numFormat(userStat['follower'])
            : '';
        onTap = () => FansPage.toFansPage(
          mid: widget.mid,
          name: coreMemberInfoModel.name,
        );
      case UserInfoType.follow:
        num = userStat['following'] ?? '';
        onTap = () => FollowPage.toFollowPage(
          mid: widget.mid,
          name: coreMemberInfoModel.name,
        );
      case UserInfoType.like:
        num = userStat['likes'] != null
            ? NumUtils.numFormat(userStat['likes'])
            : '';
    }
    return GestureDetector(
      onTap: onTap,
      child: Text(
        '$num${type.title}',
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildAvatar(String face) => GestureDetector(
    onTap: () => PageUtils.imageView(
      imgList: [CoreSourceModel(url: face)],
    ),
    child: NetworkImgLayer(
      src: face,
      type: CoreImageType.avatar,
      width: 70,
      height: 70,
    ),
  );
}
