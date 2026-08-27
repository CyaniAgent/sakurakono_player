import 'package:skf/common/widgets/flutter/list_tile.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/common/widgets/view_sliver_safe_area.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/auth_types.dart';
import 'package:skf/adapters/bilibili/pages/login_devices/controller.dart';
import 'package:skf/utils/extension/widget_ext.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:get/get.dart';

class CoreLoginDevicesPage extends StatefulWidget {
  const CoreLoginDevicesPage({super.key});

  @override
  State<CoreLoginDevicesPage> createState() => CoreLoginDevicesPageState();
}

class CoreLoginDevicesPageState extends State<CoreLoginDevicesPage> {
  final _controller = Get.put(CoreLoginDevicesController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('登录设备')),
      body: refreshIndicator(
        onRefresh: _controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: ListenableBuilder(
                listenable: _controller,
                builder: (_, _) => _buildBody(colorScheme, _controller.loadingState),
              ),
            ),
          ],
        ),
      ).constraintWidth(),
    );
  }

  Widget _buildBody(
    ColorScheme colorScheme,
    LoadingState<List<CoreLoginDevice>?> loadingState,
  ) {
    late final divider = Divider(
      height: 1,
      color: colorScheme.outline.withValues(alpha: 0.1),
    );
    return switch (loadingState) {
      Loading() => const SliverToBoxAdapter(),
      Success<List<CoreLoginDevice>?>(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.separated(
                itemBuilder: (context, index) {
                  return _buildItem(colorScheme, response[index]);
                },
                itemCount: response.length,
                separatorBuilder: (_, _) => divider,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  Widget _buildItem(ColorScheme colorScheme, CoreLoginDevice item) {
    final style = TextStyle(fontSize: 13, color: colorScheme.outline);
    return ListTile(
      dense: true,
      title: Text(
        item.deviceName ?? '',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '${item.latestLoginAt} ${item.source}',
        style: style,
      ),
      trailing: item.isCurrentDevice == true
          ? Text('(本机)', style: style)
          : null,
    );
  }
}
