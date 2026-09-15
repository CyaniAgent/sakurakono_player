import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/common/widgets/view_sliver_safe_area.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_select_topic/widgets/item.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_topic_rcmd/controller.dart';
import 'package:flutter/material.dart';
import 'package:skf/core/container/app_container.dart';

class DynTopicRcmdPage extends StatefulWidget {
  const DynTopicRcmdPage({super.key});

  @override
  State<DynTopicRcmdPage> createState() => _DynTopicRcmdPageState();
}

class _DynTopicRcmdPageState extends State<DynTopicRcmdPage> {
  final DynTopicRcmdController _controller = appRead(dynTopicRcmdControllerProvider);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('话题')),
      body: refreshIndicator(
        onRefresh: _controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: ListenableBuilder(listenable: _controller, builder: (_, _) => _buildBody(_controller.loadingState)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<CoreTopicItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => linearLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.builder(
                itemCount: response.length,
                itemBuilder: (context, index) {
                  return DynTopicItem(
                    item: response[index],
                    onTap: (item) => AppNavigator.toNamed(
                      '/dynTopic',
                      parameters: {
                        'id': item.id.toString(),
                        'name': item.name,
                      },
                    ),
                  );
                },
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}
