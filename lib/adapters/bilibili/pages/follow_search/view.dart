import 'package:skf/core/models/follow_data.dart' show CoreFollowData;
import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/models/follow_item.dart' show CoreFollowItemModel;
import 'package:skf/pages/common/search/common_search_page.dart';
import 'package:skf/pages/follow/widgets/follow_item.dart';
import 'package:skf/adapters/bilibili/pages/follow_search/controller.dart';
import 'package:flutter/material.dart';

class FollowSearchPage extends StatefulWidget {
  const FollowSearchPage({
    super.key,
    this.mid,
    this.isFromSelect = false,
  });

  final int? mid;
  final bool isFromSelect;

  @override
  State<FollowSearchPage> createState() => _FollowSearchPageState();
}

class _FollowSearchPageState
    extends
        CommonSearchPageState<FollowSearchPage, CoreFollowData, CoreFollowItemModel> {
  @override
  late final FollowSearchController controller;

  @override
  void initState() {
    super.initState();
    controller = FollowSearchController(widget.mid ?? AppNavigator.arguments['mid']);
  }

  @override
  Widget buildList(List<CoreFollowItemModel> list) {
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: ((context, index) {
        if (index == list.length - 1) {
          controller.onLoadMore();
        }
        return FollowItem(
          item: list[index],
          onSelect: widget.mid != null && widget.isFromSelect
              ? (userModel) => AppNavigator.back(result: userModel)
              : null,
        );
      }),
    );
  }
}
