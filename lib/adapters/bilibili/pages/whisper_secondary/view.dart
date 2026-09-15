import 'package:skf/common/skeleton/whisper_item.dart';
import 'package:skf/common/widgets/flutter/refresh_indicator.dart';
import 'package:skf/common/widgets/loading_widget/http_error.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart';
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/pages/whisper/widgets/item.dart';
import 'package:skf/adapters/bilibili/pages/whisper_secondary/controller.dart';
import 'package:skf/adapters/bilibili/utils/extension/three_dot_ext.dart';
import 'package:flutter/material.dart';

class WhisperSecPage extends StatefulWidget {
  const WhisperSecPage({
    super.key,
    required this.name,
    required this.sessionPageType,
  });

  final String name;
  final SessionPageType sessionPageType;

  @override
  State<WhisperSecPage> createState() => _WhisperSecPageState();
}

class _WhisperSecPageState extends State<WhisperSecPage> {
  late final WhisperSecController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WhisperSecController(sessionPageType: widget.sessionPageType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (_, _) {
              final threeDotItems = _controller.threeDotItems;
              if (threeDotItems != null && threeDotItems.isNotEmpty) {
                return PopupMenuButton(
                  itemBuilder: (context) {
                    return threeDotItems
                        .map(
                          (e) => PopupMenuItem(
                            onTap: () => e.type.action(
                              context: context,
                              controller: _controller,
                              item: e,
                            ),
                            child: Row(
                              children: [
                                e.type.icon,
                                Text('  ${e.title}'),
                              ],
                            ),
                          ),
                        )
                        .toList();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: refreshIndicator(
        onRefresh: _controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: ListenableBuilder(listenable: _controller, builder: (_, _) => _buildBody(_controller.loadingState)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState<List<Session>?> loadingState) {
    late final divider = Divider(
      indent: 72,
      endIndent: 20,
      height: 1,
      color: Colors.grey.withValues(alpha: 0.1),
    );
    return switch (loadingState) {
      Loading() => SliverList.builder(
        itemCount: 12,
        itemBuilder: (context, index) => const WhisperItemSkeleton(),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.separated(
                itemCount: response.length,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  final item = response[index];
                  return WhisperSessionItem(
                    item: item,
                    onSetTop: (isTop, talkerId) =>
                        _controller.onSetTop(
                          item, index, isTop,
                          CoreImSessionId(
                            privateTalkerUid: talkerId.hasPrivateId()
                                ? talkerId.privateId.talkerUid.toInt()
                                : null,
                          ),
                        ),
                    onSetMute: (isMuted, talkerUid) =>
                        _controller.onSetMute(item, isMuted, talkerUid.toInt()),
                    onRemove: (talkerId) =>
                        _controller.onRemove(index, talkerId),
                  );
                },
                separatorBuilder: (context, index) => divider,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}
