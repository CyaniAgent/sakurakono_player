import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/view_sliver_safe_area.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/adapters/bilibili/pages/subscription/controller.dart';
import 'package:skf/adapters/bilibili/pages/subscription/widgets/item.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:skf/core/container/app_container.dart';

class SubPage extends StatefulWidget {
  const SubPage({super.key});

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> with GridMixin {
  final SubController _subController = appRead(subControllerProvider);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('我的订阅')),
      body: refreshIndicator(
        onRefresh: _subController.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: ListenableBuilder(
                listenable: _subController,
                builder: (_, _) => _buildBody(_subController.loadingState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<CoreSubItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _subController.onLoadMore();
                  }
                  final item = response[index];
                  return SubItem(
                    item: ModelConverters.subItemModel(item),
                    cancelSub: () => _subController.cancelSub(item),
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _subController.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _subController.onReload,
      ),
    };
  }
}
