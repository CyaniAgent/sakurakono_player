// 收藏夹详情页。
//
// 版式复原自原 fav_detail(bb7d917 快照):SliverAppBar.medium 折叠头部
// (夹名 + 共 N 条视频)+ flexibleSpace 信息卡(Hero 封面 + 标题 +
// UP 名 + 简介 + 条数)。内容按收藏夹(合集)过滤;OttoHub 无取消收藏/
// 多选/搜索等扩展操作 API,对应入口不提供。

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

  /// 收藏夹 ID(OttoHub 侧为列表下标合成,仅作展示 key,内容过滤以夹名为准)。
  final int mediaId;
  final String? heroTag;

  /// 入口传入的收藏夹信息(标题用于按夹过滤,其余由接口回填)。
  final CoreFavFolderInfo? folder;

  @override
  State<FavDetailPage> createState() => _FavDetailPageState();
}

class _FavDetailPageState extends State<FavDetailPage> with GridMixin {
  static const _pageSize = 20;

  /// 收藏夹信息:先展示入口传入值,首屏加载后用接口返回的真实信息回填。
  CoreFavFolderInfo? _folderInfo;

  final List<CoreFavDetailItemModel> _items = <CoreFavDetailItemModel>[];
  bool _hasMore = true;
  bool _isLoading = false;
  bool _firstLoaded = false;

  /// 加载更多进行中收到下拉刷新:记下,当前查询结束后补一次。
  bool _pendingRefresh = false;
  String? _errMsg;
  int _pn = 1;

  @override
  void initState() {
    super.initState();
    _folderInfo = widget.folder;
    _query(more: false);
  }

  Future<void> _query({required bool more}) async {
    if (_isLoading) {
      if (!more) _pendingRefresh = true;
      return;
    }
    if (more && !_hasMore) return;
    _isLoading = true;
    if (!more) _pn = 1;
    final res = await appRead(favRepositoryProvider).userFavFolderDetail(
      mediaId: widget.mediaId,
      pn: _pn,
      ps: _pageSize,
      collection: widget.folder?.title,
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
            if (response.info?.title.isNotEmpty == true) {
              _folderInfo = response.info;
            }
          }
          _hasMore = response.hasMore == true;
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
    if (_pendingRefresh && mounted) {
      _pendingRefresh = false;
      await _query(more: false);
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
      body: refreshIndicator(
        onRefresh: () => _query(more: false),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            if (!_firstLoaded) ...[
              if (_errMsg == null)
                SliverPadding(
                  padding: const EdgeInsets.only(top: 7, bottom: 100),
                  sliver: gridSkeleton,
                )
              else
                SliverToBoxAdapter(
                  child: HttpError(
                    errMsg: _errMsg,
                    onReload: () => _query(more: false),
                  ),
                ),
            ] else if (_items.isEmpty)
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

  /// 折叠头部:夹名 + 共 N 条视频(bb7d917 同款)。
  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final folder = _folderInfo;
    return SliverAppBar.medium(
      expandedHeight: kToolbarHeight + 127,
      pinned: true,
      title: folder == null
          ? const Text('我的收藏')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(folder.title, style: theme.textTheme.titleMedium),
                Text(
                  '共${folder.mediaCount}条视频',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
      flexibleSpace: folder == null ? null : _flexibleSpace(theme, folder),
    );
  }

  /// 信息卡:Hero 封面 + 标题 + UP 名 + 简介 + 条数(bb7d917 同款;
  /// 公开/私密与收藏按钮 OttoHub 无对应数据,不展示)。
  Widget _flexibleSpace(ThemeData theme, CoreFavFolderInfo folder) {
    final style = TextStyle(
      height: 1,
      fontSize: 12.5,
      color: theme.colorScheme.outline,
    );
    final padding = MediaQuery.paddingOf(context);
    final cover = NetworkImgLayer(width: 176, height: 110, src: folder.cover);
    return FlexibleSpaceBar(
      background: Padding(
        padding: EdgeInsets.only(
          top: kToolbarHeight + padding.top + 10,
          left: 12 + padding.left,
          right: 12,
          bottom: 7,
        ),
        child: SizedBox(
          height: 110,
          child: Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.heroTag != null
                  ? Hero(tag: widget.heroTag!, child: cover)
                  : cover,
              if (folder.title.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          folder.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: theme.textTheme.titleMedium!.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (folder.upper?.name?.isNotEmpty == true)
                        GestureDetector(
                          onTap: () => AppNavigator.toNamed(
                            '/member?mid=${folder.upper!.mid}',
                          ),
                          child: Text(
                            folder.upper!.name!,
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (folder.intro?.isNotEmpty == true) ...[
                        Text(
                          folder.intro!,
                          style: style,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text('共${folder.mediaCount}条视频', style: style),
                    ],
                  ),
                ),
            ],
          ),
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
