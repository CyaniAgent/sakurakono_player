// OttoHub 搜索结果面板(视频域)。
//
// 注入框架 SearchResultPage.panelBuilder:按关键词分页搜索
// (searchAll),结果以横向视频卡网格展示。OttoHub 仅视频域可搜,
// 其余 tab(番剧/影视/直播间/专栏)无对应内容。

import 'package:flutter/material.dart';

import 'package:skf/adapters/ottohub/services/otto_video_related_panel.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart'
    show refreshIndicator;
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/utils/grid.dart';

class OttoSearchResultPanel extends StatefulWidget {
  const OttoSearchResultPanel({super.key, required this.keyword});

  final String keyword;

  @override
  State<OttoSearchResultPanel> createState() => _OttoSearchResultPanelState();
}

class _OttoSearchResultPanelState extends State<OttoSearchResultPanel>
    with GridMixin {
  final List<CoreHotVideoItemModel> _items = <CoreHotVideoItemModel>[];
  bool _hasMore = true;
  bool _isLoading = false;
  bool _firstLoaded = false;
  String? _errMsg;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _query(more: false);
  }

  Future<void> _query({required bool more}) async {
    if (_isLoading || (more && !_hasMore)) return;
    _isLoading = true;
    if (!more) _page = 1;
    final res = await appRead(
      searchRepositoryProvider,
    ).searchAll(keyword: widget.keyword, page: _page);
    if (!mounted) return;
    _isLoading = false;
    switch (res) {
      case Success(:final response):
        setState(() {
          final page = (response.list ?? const <Object?>[])
              .whereType<Map<String, dynamic>>()
              .map(CoreHotVideoItemModel.fromJson)
              .toList();
          if (more) {
            _items.addAll(page);
          } else {
            _items
              ..clear()
              ..addAll(page);
            _firstLoaded = true;
            _errMsg = null;
          }
          _hasMore = page.length >= 30;
          _page += 1;
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

  @override
  Widget build(BuildContext context) {
    if (!_firstLoaded) {
      // tab 页 box 上下文:骨架 Sliver 包进滚动视图,错误态 isSliver:false。
      if (_errMsg == null) {
        return refreshIndicator(
          onRefresh: () => _query(more: false),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 7, bottom: 100),
                sliver: gridSkeleton,
              ),
            ],
          ),
        );
      }
      return HttpError(
        isSliver: false,
        errMsg: _errMsg,
        onReload: () => _query(more: false),
      );
    }
    if (_items.isEmpty) {
      return refreshIndicator(
        onRefresh: () => _query(more: false),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('没有找到相关内容')),
            ),
          ],
        ),
      );
    }
    return refreshIndicator(
      onRefresh: () => _query(more: false),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 7, bottom: 100),
            sliver: SliverGrid.builder(
              gridDelegate: gridDelegate,
              itemBuilder: (context, index) {
                if (index == _items.length - 1 && _hasMore) {
                  _query(more: true);
                }
                return OttoVideoCardH(videoItem: _items[index]);
              },
              itemCount: _items.length,
            ),
          ),
        ],
      ),
    );
  }
}

/// 无对应内容域的搜索 tab 占位。
class OttoSearchUnsupportedPanel extends StatelessWidget {
  const OttoSearchUnsupportedPanel({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('暂不支持该搜索类型'));
}
