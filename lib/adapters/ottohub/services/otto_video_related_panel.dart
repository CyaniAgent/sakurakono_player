// OttoHub 相关视频面板。
//
// 版式复原自原 B站 适配器 RelatedVideoPanel + VideoCardH(bb7d917 快照):
// SliverPadding(top 7, bottom 100) + SliverGrid(GridMixin) + 横向卡片
// (16:9 封面 + 时长角标 + 两行标题 + UP/日期行 + StatWidget 行)。
// 数据来自 VideoRepository.relatedVideoList;点击跳框架视频页 /videoV,
// 参数形状与推荐页卡片一致。

import 'package:flutter/material.dart';

import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/badge.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/stat/stat.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/cover_ratio.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/utils/utils.dart';

class OttoVideoRelatedPanel extends StatefulWidget {
  const OttoVideoRelatedPanel({super.key, required this.bvid});

  /// OttoHub 视频 ID(纯数字字符串)。
  final String bvid;

  @override
  State<OttoVideoRelatedPanel> createState() => _OttoVideoRelatedPanelState();
}

class _OttoVideoRelatedPanelState extends State<OttoVideoRelatedPanel>
    with GridMixin {
  LoadingState<List<CoreHotVideoItemModel>> _state =
      LoadingState<List<CoreHotVideoItemModel>>.loading();

  @override
  void initState() {
    super.initState();
    _query();
  }

  Future<void> _query() async {
    setState(() {
      _state = LoadingState<List<CoreHotVideoItemModel>>.loading();
    });
    final res = await appRead(
      videoRepositoryProvider,
    ).relatedVideoList(bvid: widget.bvid);
    if (!mounted) return;
    switch (res) {
      case Success(:final response):
        setState(
          () => _state = Success(response ?? <CoreHotVideoItemModel>[]),
        );
      case final Error err:
        setState(() => _state = Error(err.errMsg, code: err.code));
      case Loading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 7, bottom: 100),
      sliver: _buildBody(_state),
    );
  }

  Widget _buildBody(LoadingState<List<CoreHotVideoItemModel>> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) => response.isNotEmpty
          ? SliverGrid.builder(
              gridDelegate: gridDelegate,
              itemBuilder: (context, index) =>
                  OttoVideoCardH(videoItem: response[index]),
              itemCount: response.length,
            )
          : const SliverToBoxAdapter(),
      Error(:final errMsg) => HttpError(errMsg: errMsg, onReload: _query),
    };
  }
}

/// 横向视频卡片(复原原 VideoCardH 版式;封面保存/弹出菜单等
/// B站 专属能力不移植)。公开供用户页投稿 tab 复用。
class OttoVideoCardH extends StatelessWidget {
  const OttoVideoCardH({super.key, required this.videoItem});

  final CoreHotVideoItemModel videoItem;

  void _onTap() {
    if (videoItem.cid == null && videoItem.aid == null) return;
    AppNavigator.toNamed(
      '/videoV',
      preventDuplicates: false,
      arguments: <String, dynamic>{
        'aid': videoItem.aid,
        'bvid': videoItem.bvid,
        'cid': videoItem.cid ?? videoItem.aid,
        'cover': videoItem.cover,
        'title': videoItem.title,
        'heroTag': Utils.makeHeroTag(videoItem.cid ?? videoItem.aid),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimension = videoItem.dimension ?? const <String, dynamic>{};
    return Material(
      type: .transparency,
      child: InkWell(
        onTap: _onTap,
        child: Padding(
          padding: const .symmetric(
            horizontal: Style.safeSpace,
            vertical: 5,
          ),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              AspectRatio(
                aspectRatio: coverAspectRatio(
                  dimension['width'] as num?,
                  dimension['height'] as num?,
                ),
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    final maxWidth = boxConstraints.maxWidth;
                    final maxHeight = boxConstraints.maxHeight;
                    return Stack(
                      clipBehavior: .none,
                      children: [
                        NetworkImgLayer(
                          src: videoItem.cover,
                          width: maxWidth,
                          height: maxHeight,
                        ),
                        if (videoItem.duration != null &&
                            videoItem.duration! > 0)
                          PBadge(
                            text: DurationUtils.formatDuration(
                              videoItem.duration,
                            ),
                            right: 6.0,
                            bottom: 6.0,
                            type: .gray,
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              content(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget content(ThemeData theme) {
    final owner = videoItem.owner ?? const <String, dynamic>{};
    final stat = videoItem.stat ?? const <String, dynamic>{};
    String pubdate = DateFormatUtils.dateFormat(videoItem.pubdate);
    if (pubdate != '') pubdate += '  ';
    return Expanded(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: Text(
              videoItem.title ?? '',
              textAlign: .start,
              style: TextStyle(
                fontSize: theme.textTheme.bodyMedium!.fontSize,
                height: 1.42,
                letterSpacing: 0.3,
              ),
              maxLines: 2,
              overflow: .ellipsis,
            ),
          ),
          Text(
            '$pubdate${owner['name'] ?? ''}',
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              height: 1,
              color: theme.colorScheme.outline,
              overflow: .clip,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            spacing: 8,
            children: [
              StatWidget(type: .play, value: stat['view']),
              StatWidget(type: .danmaku, value: stat['danmu']),
            ],
          ),
        ],
      ),
    );
  }
}
