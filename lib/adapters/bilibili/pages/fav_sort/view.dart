import 'package:skf/common/widgets/reorder_mixin.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/adapters/bilibili/pages/fav_detail/controller.dart';
import 'package:skf/adapters/bilibili/pages/fav_detail/widget/fav_video_card.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FavSortPage extends StatefulWidget {
  const FavSortPage({super.key, required this.favDetailController});

  final FavDetailController favDetailController;

  @override
  State<FavSortPage> createState() => _FavSortPageState();
}

class _FavSortPageState extends State<FavSortPage> with ReorderMixin {
  FavDetailController get _favDetailController => widget.favDetailController;

  late List<CoreFavDetailItemModel> sortList = List<CoreFavDetailItemModel>.from(
    _favDetailController.loadingState.data!,
  );
  List<String> sort = <String>[];

  void onLoadMore() {
    if (_favDetailController.isEnd) {
      return;
    }
    _favDetailController.onLoadMore().whenComplete(() {
      try {
        if (_favDetailController.loadingState case Success(
          :final response,
        )) {
          if (response == null || sortList.length >= response.length) return;
          sortList.addAll(response.skip(sortList.length));
          if (mounted) {
            setState(() {});
          }
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('排序: ${_favDetailController.folderInfo.title}'),
        actions: [
          TextButton(
            onPressed: () {
              if (sort.isEmpty) {
                AppNavigator.back();
                return;
              }
              appRead(favRepositoryProvider).sortFav(
                mediaId: _favDetailController.mediaId.toString(),
                sort: sort.join(','),
              ).then((res) {
                if (res.isSuccess) {
                  SmartDialog.showToast('排序完成');
                  _favDetailController.loadingState = Success(sortList);
                  if (mounted) {
                    AppNavigator.back();
                  }
                } else {
                  res.toast();
                }
              });
            },
            child: const Text('完成'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody,
    );
  }

  void onReorderItem(int oldIndex, int newIndex) {
    final oldItem = sortList[oldIndex];
    final newItem = sortList.getOrNull(
      oldIndex > newIndex ? newIndex - 1 : newIndex, // might be Negative
    );
    sort.add(
      '${newItem == null ? '0:0' : '${newItem.id}:${newItem.type}'}:${oldItem.id}:${oldItem.type}',
    );

    sortList.insert(newIndex, sortList.removeAt(oldIndex));

    setState(() {});
  }

  Widget get _buildBody {
    final child = ReorderableListView.builder(
      onReorderItem: onReorderItem,
      proxyDecorator: proxyDecorator,
      physics: const AlwaysScrollableScrollPhysics(),
      padding:
          MediaQuery.viewPaddingOf(context).copyWith(top: 0) +
          const EdgeInsets.only(bottom: 100),
      itemCount: sortList.length,
      itemBuilder: (context, index) {
        final item = sortList[index];
        return SizedBox(
          key: ValueKey(item.id),
          height: 110,
          child: FavVideoCardH(item: item),
        );
      },
    );
    if (!_favDetailController.isEnd) {
      return NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 300) {
            onLoadMore();
          }
          return false;
        },
        child: child,
      );
    }
    return child;
  }
}
