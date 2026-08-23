import 'package:skf/common/skeleton/msg_feed_top.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/models/blacklist_item.dart' show CoreBlackListItem;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/ui/image_type.dart';
import 'package:skf/pages/blacklist/controller.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/date_utils.dart';
import 'package:skf/utils/global_data.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlackListPage extends StatefulWidget {
  const BlackListPage({super.key});

  @override
  State<BlackListPage> createState() => _BlackListPageState();
}

class _BlackListPageState extends State<BlackListPage> {
  final _blackListController = Get.put(BlackListController());

  @override
  void dispose() {
    if (_blackListController.loadingState case Success(:final response)) {
      final blackMids = response?.map((e) => e.mid!).toSet() ?? {};
      GlobalData().blackMids = blackMids;
      Pref.blackMids = blackMids;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: ListenableBuilder(
          listenable: _blackListController,
          builder: (context, _) => Text(
            '黑名单管理${_blackListController.total == -1 ? '' : ': ${_blackListController.total}'}',
          ),
        ),
      ),
      body: refreshIndicator(
        onRefresh: _blackListController.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _blackListController.scrollController,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: ListenableBuilder(
                listenable: _blackListController,
                builder: (_, _) => _buildBody(_blackListController.loadingState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<CoreBlackListItem>?> loadingState) {
    late final style = TextStyle(color: Theme.of(context).colorScheme.outline);
    return switch (loadingState) {
      Loading() => SliverList.builder(
        itemCount: 12,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.builder(
                itemCount: response.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == response.length - 1) {
                    _blackListController.onLoadMore();
                  }
                  final item = response[index];
                  return ListTile(
                    visualDensity: .standard,
                    onTap: () => AppNavigator.toNamed('/member?mid=${item.mid}'),
                    leading: NetworkImgLayer(
                      width: 45,
                      height: 45,
                      type: CoreImageType.avatar,
                      src: item.face,
                    ),
                    title: Text(
                      item.uname!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      '添加时间: ${DateFormatUtils.format(item.mtime, format: DateFormatUtils.longFormatDs)}',
                      maxLines: 1,
                      style: style,
                      overflow: TextOverflow.ellipsis,
                    ),
                    dense: true,
                    trailing: TextButton(
                      onPressed: () => _blackListController.onRemove(
                        context,
                        index,
                        item.uname,
                        item.mid,
                      ),
                      child: const Text('移除'),
                    ),
                  );
                },
              )
            : HttpError(onReload: _blackListController.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _blackListController.onReload,
      ),
    };
  }
}
