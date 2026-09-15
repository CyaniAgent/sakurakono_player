import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/search/common_search_page.dart';
import 'package:skf/pages/download/detail/widgets/item.dart';
import 'package:skf/pages/download/download_actions.dart';
import 'package:skf/pages/download/search/controller.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';

class DownloadSearchPage extends StatefulWidget {
  const DownloadSearchPage({
    super.key,
    required this.progress,
  });

  final ChangeNotifier progress;

  @override
  State<DownloadSearchPage> createState() => _DownloadSearchPageState();
}

class _DownloadSearchPageState
    extends
        CommonSearchPageState<
          DownloadSearchPage,
          List<CoreDownloadEntryInfo>,
          CoreDownloadEntryInfo
        >
    with GridMixin {
  @override
  DownloadSearchController controller = appRead(downloadSearchControllerProvider);
  final _downloadActions = DownloadActions.of();

  @override
  List<Widget>? get extraActions => [
    IconButton(
      tooltip: '多选',
      onPressed: () {
        if (controller.loadingState is! Success) {
          return;
        }
        if (controller.enableMultiSelect) {
          controller.handleSelect();
        } else {
          controller.enableMultiSelect = true;
        }
      },
      icon: const Icon(Icons.edit_note),
    ),
  ];

  @override
  List<Widget>? get multiSelectActions => [
    TextButton(
      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
      onPressed: () async {
        final future = controller.allChecked
            .map(
              (e) => _downloadActions.downloadDanmaku(
                entry: e,
                isUpdate: true,
              ),
            )
            .toList();
        controller.handleSelect();
        final res = await Future.wait(future);
        if (res.every((e) => e)) {
          SmartDialog.showToast('更新成功');
        } else {
          SmartDialog.showToast('更新失败');
        }
      },
      child: Text(
        '更新',
        style: TextStyle(color: ColorScheme.of(context).onSurface),
      ),
    ),
  ];

  @override
  Widget buildList(List<CoreDownloadEntryInfo> list) {
    if (list.isNotEmpty) {
      return SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemBuilder: (context, index) {
          final entry = list[index];
          return DetailItem(
            entry: entry,
            progress: widget.progress,
            actions: _downloadActions,
            showTitle: true,
            onDelete: () => controller.onRemoveSingle(index, entry),
            controller: controller,
          );
        },
        itemCount: list.length,
      );
    }
    return const HttpError();
  }
}
