import 'package:skf/core/models/follow_data.dart' show CoreFollowData;
import 'package:skf/core/models/follow_item.dart' show CoreFollowItemModel;
import 'package:skf/adapters/bilibili/pages/common/search/common_search_page.dart';
import 'package:skf/adapters/bilibili/pages/follow/widgets/follow_item.dart';
import 'package:skf/adapters/bilibili/pages/follow_search/controller.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    controller = Get.put(
      FollowSearchController(widget.mid ?? Get.arguments['mid']),
      tag: Utils.generateRandomString(8),
    );
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
          item: ModelConverters.followItem(list[index]),
          onSelect: widget.mid != null && widget.isFromSelect
              ? (userModel) => Get.back(result: userModel)
              : null,
        );
      }),
    );
  }
}
