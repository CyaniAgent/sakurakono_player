// OttoHub 视频简介面板(投稿视频)。
//
// 版式复原自原 B站 适配器 UgcIntroPanel(bb7d917 快照):
// TranslucentColumn + UP主行(挂件头像) + 可展开标题 + StatWidget
// 信息行 + 简介 + 点赞/分享操作行。数据来自
// OttoVideoRepository.videoIntro(bvid = OttoHub 纯数字 vid);
// OttoHub 无 关注/投币/收藏 API,B站 概念按钮(点踩/投币/收藏/
// 再看)不展示。成功后回写 hub 页面状态(标题/评论数/UP mid),
// 评论 tab 计数、UP 徽章与播放器头部随之刷新。

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:skf/adapters/ottohub/services/otto_action_item.dart';
import 'package:skf/adapters/ottohub/services/otto_video_page_hub.dart';
import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/animated_height.dart';
import 'package:skf/common/widgets/expandable.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/pendant_avatar.dart';
import 'package:skf/common/widgets/selection_text.dart';
import 'package:skf/common/widgets/stat/stat.dart';
import 'package:skf/common/widgets/translucent_column.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/num_utils.dart';
import 'package:skf/utils/utils.dart';

class OttoVideoIntroPanel extends StatefulWidget {
  const OttoVideoIntroPanel({
    super.key,
    required this.hub,
    required this.heroTag,
    required this.bvid,
  });

  final OttoVideoPageHub hub;
  final String heroTag;

  /// OttoHub 视频 ID(纯数字字符串)。
  final String bvid;

  @override
  State<OttoVideoIntroPanel> createState() => _OttoVideoIntroPanelState();
}

class _OttoVideoIntroPanelState extends State<OttoVideoIntroPanel> {
  late ColorScheme colorScheme;
  LoadingState<CoreVideoDetailData> _state =
      LoadingState<CoreVideoDetailData>.loading();
  bool _expand = false;

  /// 点赞状态(OttoHub 服务端不回传初始态,进入页面按未点赞处理)。
  bool _hasLike = false;
  int? _likeCount;

  @override
  void initState() {
    super.initState();
    _query();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorScheme = ColorScheme.of(context);
  }

  Future<void> _query() async {
    setState(() {
      _state = LoadingState<CoreVideoDetailData>.loading();
    });
    final res = await appRead(
      videoRepositoryProvider,
    ).videoIntro(bvid: widget.bvid);
    if (!mounted) return;
    switch (res) {
      case Success(:final response):
        setState(() {
          _state = Success(response);
          _likeCount = _statInt(response.stat, 'like');
        });
        widget.hub
            .state(widget.heroTag)
          ..title = response.title ?? ''
          ..commentCount = _statInt(response.stat, 'danmu')
          ..upMid = (response.owner?['mid'] as num?)?.toInt() ?? -1;
      case final Error err:
        setState(() => _state = Error(err.errMsg, code: err.code));
      case Loading():
        break;
    }
  }

  static int _statInt(Map<String, dynamic>? stat, String key) =>
      (stat?[key] as num?)?.toInt() ?? 0;

  Future<void> _actionLike() async {
    final res = await appRead(
      videoRepositoryProvider,
    ).likeVideo(bvid: widget.bvid, type: !_hasLike);
    if (!mounted) return;
    if (res case Success(:final response)) {
      final liked = response == '1';
      setState(() {
        _hasLike = liked;
        _likeCount = (_likeCount ?? 0) + (liked ? 1 : -1);
      });
    } else {
      res.toast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const .only(
        left: Style.safeSpace,
        right: Style.safeSpace,
        top: 10,
      ),
      sliver: SliverToBoxAdapter(
        child: ListenableBuilder(
          listenable: widget.hub.state(widget.heroTag),
          builder: (context, _) => switch (_state) {
            Loading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            Error() => HttpError(
              isSliver: false,
              errMsg: _state is Error ? (_state as Error).errMsg : null,
              onReload: _query,
            ),
            Success(:final response) => _buildBody(response),
          },
        ),
      ),
    );
  }

  Widget _buildBody(CoreVideoDetailData videoDetail) {
    final isLoading = videoDetail.bvid == null;
    return GestureDetector(
      onTap: () {
        if (isLoading) return;
        setState(() => _expand = !_expand);
      },
      child: TranslucentColumn(
        crossAxisAlignment: .start,
        children: [
          NoTranslucentArea(child: _buildOwnerInfo(videoDetail)),
          const SizedBox(height: 8),
          _buildTitle(videoDetail),
          const SizedBox(height: 8),
          _buildInfo(videoDetail.stat, videoDetail.pubdate),
          AnimatedHeight(
            expand: _expand,
            duration: const Duration(milliseconds: 300),
            child: TranslucentColumn(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: _infos(videoDetail),
            ),
          ),
          // 点赞收藏转发
          const SizedBox(height: 8),
          actionGrid(videoDetail.stat),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo(CoreVideoDetailData videoDetail) {
    final owner = videoDetail.owner ?? const <String, dynamic>{};
    final mid = owner['mid'] as int?;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: .centerLeft,
            child: GestureDetector(
              behavior: .opaque,
              onTap: () {
                if (mid != null) {
                  AppNavigator.toNamed('/member?mid=$mid');
                }
              },
              child: Row(
                spacing: 10,
                mainAxisSize: .min,
                children: [
                  PendantAvatar(owner['face'] as String?, size: 35),
                  Text(
                    owner['name'] as String? ?? '',
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(CoreVideoDetailData videoDetail) {
    return ListenableBuilder(
      listenable: widget.hub.state(widget.heroTag),
      builder: (context, _) => ExpandablePanel(
        collapsed: _gestureVideoTitle(videoDetail),
        expanded: _gestureVideoTitle(videoDetail, isExpand: true),
        expand: _expand,
      ),
    );
  }

  Widget _gestureVideoTitle(
    CoreVideoDetailData videoDetail, {
    bool isExpand = false,
  }) {
    return GestureDetector(
      onLongPress: () {
        Utils.copyText(videoDetail.title ?? '');
      },
      child: Text.rich(
        TextSpan(children: [TextSpan(text: videoDetail.title ?? '')]),
        maxLines: isExpand ? null : 2,
        overflow: isExpand ? null : .ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  List<Widget> _infos(CoreVideoDetailData videoDetail) => [
    const SizedBox(height: 8, width: .infinity),
    GestureDetector(
      onTap: () => Utils.copyText('${videoDetail.bvid}'),
      child: Text(
        videoDetail.bvid ?? '',
        style: TextStyle(fontSize: 14, color: colorScheme.secondary),
      ),
    ),
    if (videoDetail.desc?.isNotEmpty == true) ...[
      const SizedBox(height: 8),
      SelectionText(
        videoDetail.desc!,
        style: const TextStyle(height: 1.4, fontSize: 14),
      ),
    ],
  ];

  Widget _buildInfo(Map<String, dynamic>? stat, int? pubdate) {
    return Row(
      spacing: 10,
      children: [
        StatWidget(
          type: .play,
          value: stat?['view'],
          color: colorScheme.outline,
        ),
        StatWidget(
          type: .danmaku,
          value: stat?['danmu'],
          color: colorScheme.outline,
        ),
        Text(
          DateFormatUtils.format(pubdate),
          style: TextStyle(fontSize: 12, color: colorScheme.outline),
        ),
      ],
    );
  }

  Widget actionGrid(Map<String, dynamic>? stat) {
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: .start,
        children: [
          OttoActionItem(
            icon: const Icon(FontAwesomeIcons.thumbsUp),
            selectIcon: const Icon(FontAwesomeIcons.solidThumbsUp),
            onTap: _actionLike,
            selectStatus: _hasLike,
            semanticsLabel: '点赞',
            text: NumUtils.numFormat(_likeCount),
          ),
          OttoActionItem(
            icon: const Icon(FontAwesomeIcons.shareFromSquare),
            onTap: () => Utils.copyText(widget.bvid),
            selectStatus: false,
            semanticsLabel: '分享',
          ),
        ],
      ),
    );
  }
}
