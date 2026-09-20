// 收藏夹详情页(轻量复原)。
//
// 分页加载收藏内容(GridMixin 网格 + 骨架屏),点击跳框架视频页。
// 多选/取消收藏/转发等扩展操作 OttoHub 服务端无对应 API,不提供。

import 'package:flutter/material.dart';

import 'package:skf/common/widgets/badge.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart'
    show refreshIndicator;
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/utils/grid.dart';
import 'package:skf/utils/utils.dart';

class FavDetailPage extends StatefulWidget {
  const FavDetailPage({
    super.key,
    required this.mediaId,
    this.heroTag,
    this.folder,
  });

  /// 收藏夹 ID(OttoHub 当前按收藏总量分页,忽略夹 ID)。
  final int mediaId;
  final String? heroTag;

  /// 入口传入的收藏夹信息(仅取标题)。
  final CoreFavFolderInfo? folder;

  @override
  State<FavDetailPage> createState() => _FavDetailPageState();
}

class _FavDetailPageState extends State<FavDetailPage> with GridMixin {
  static const _pageSize = 20;

  final List<CoreFavDetailItemModel> _items = <CoreFavDetailItemModel>[];
  bool _hasMore = true;
  bool _isLoading = false;
  bool _firstLoaded = false;
  String? _errMsg;
  int _pn = 1;

  @override
  void initState() {
    super.initState();
    _query(more: false);
  }

  Future<void> _query({required bool more}) async {
    if (_isLoading || (more && !_hasMore)) return;
    _isLoading = true;
    if (!more) _pn = 1;
    final res = await appRead(favRepositoryProvider).userFavFolderDetail(
      mediaId: widget.mediaId,
      pn: _pn,
      ps: _pageSize,
    );
    if (!mounted) return;
    _isLoading = false;
    switch (res) {
      case Success(:final response):
        setState(() {
          final page = response.medias ?? <CoreFavDetailItemModel>[];
          if (more) {
            _items.addAll(page);
          } else {
            _items
              ..clear()
              ..addAll(page);
            _firstLoaded = true;
            _errMsg = null;
          }
          _hasMore = page.length >= _pageSize;
          _pn += 1;
        });
      case final Error err:
        if (more) {
          setState(() => _hasMore = false);
        } else {
          setState(() => _errMsg = err.errMsg ?? '加载失败');
        }
      case Loading():
        break;
    }
  }

  void _onTapItem(CoreFavDetailItemModel item) {
    final vid = item.id;
    if (vid == null) return;
    AppNavigator.toNamed(
      '/videoV',
      preventDuplicates: false,
      arguments: <String, dynamic>{
        'aid': vid,
        'bvid': item.bvid ?? '$vid',
        'cid': vid,
        'cover': item.cover,
        'title': item.title,
        'heroTag': Utils.makeHeroTag(vid),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder?.title ?? '我的收藏')),
      body: !_firstLoaded
          ? (_errMsg == null
                ? gridSkeleton
                : HttpError(errMsg: _errMsg, onReload: () => _query(more: false)))
          : refreshIndicator(
              onRefresh: () => _query(more: false),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_items.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('收藏夹是空的')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 7, bottom: 100),
                      sliver: SliverGrid.builder(
                        gridDelegate: gridDelegate,
                        itemBuilder: (context, index) {
                          if (index == _items.length - 1 && _hasMore) {
                            _query(more: true);
                          }
                          return _buildItem(_items[index]);
                        },
                        itemCount: _items.length,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildItem(CoreFavDetailItemModel item) {
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _onTapItem(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    NetworkImgLayer(
                      src: item.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    if (item.duration != null && item.duration! > 0)
                      PBadge(
                        text: DurationUtils.formatDuration(item.duration),
                        right: 6.0,
                        bottom: 6.0,
                        type: .gray,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title ?? '',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: theme.textTheme.bodyMedium!.fontSize,
                          height: 1.42,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.upper?.name ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                        color: theme.colorScheme.outline,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
