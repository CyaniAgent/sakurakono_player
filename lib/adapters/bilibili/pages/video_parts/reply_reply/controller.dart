import 'package:skf/core/models/reply_types.dart' show CoreMode;
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo, DetailListReply;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/repository/repository_providers.dart';

import 'package:skf/adapters/bilibili/pages/common/publish/publish_route.dart';
import 'package:skf/adapters/bilibili/pages/common/reply_controller.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply_new/view.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:skf/core/container/app_container.dart';

class VideoReplyReplyController extends ReplyController {
  VideoReplyReplyController({
    required this.hasRoot,
    required this.id,
    required this.oid,
    required this.rpid,
    required this.dialog,
    required this.replyType,
  }) {
    mode = CoreMode.mainListTime;
    queryData();
  }
  final int? dialog;
  int? id;
  // 视频aid 请求时使用的oid
  int oid;
  // rpid 请求楼中楼回复
  int rpid;
  int replyType;

  bool hasRoot = false;
  ReplyInfo? firstFloor;

  int? index;

  final listController = ListController();

  AnimationController? _controller;
  AnimationController get animController => _controller ??= AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: _tickerProvider,
  );

  final _TickerProvider _tickerProvider = _TickerProvider();

  late final horizontalPreview = Pref.horizontalPreview;

  void didChangeDependencies(BuildContext context) {}

  @override
  dynamic get sourceId => replyType == 1 ? IdUtils.av2bv(oid) : oid;


  @override
  List<ReplyInfo>? getDataList(response) {
    return dialog != null ? response.replies : response.root.replies;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success response) {
    final data = response.response;

    subjectControl = data.subjectControl;
    upMid ??= data.subjectControl.upMid;
    paginationReply = data.paginationReply;
    isEnd = data.cursor.isEnd;

    // reply2Reply // isDialogue.not
    if (data is DetailListReply) {
      count = data.root.count.toInt();
      if (isRefresh && !hasRoot) {
        firstFloor ??= data.root;
      }
      if (id != null) {
        setIndexById(Int64(id!), data.root.replies);
        id = null;
      }
    }

    return false;
  }

  bool setIndexById(Int64 id64, [List<ReplyInfo>? replies]) {
    final index = (replies ?? loadingState.data!).indexWhere(
      (item) => item.id == id64,
    );
    if (index != -1) {
      this.index = index;
      jumpToItem(index);
      return true;
    }
    return false;
  }

  ExtendedNestedScrollController? nestedController;

  @pragma('vm:notify-debugger-on-exception')
  void jumpToItem(int index) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      animController.forward(from: 0);
      try {
        // ignore: invalid_use_of_visible_for_testing_member
        final offset = listController.getOffsetToReveal(index, 0.25);
        if (offset.isFinite) {
          if (nestedController case final nestedController?) {
            nestedController.nestedPositions.last.localJumpTo(offset);
          } else {
            scrollController.jumpTo(offset);
          }
        }
      } catch (_) {}
    });
  }

  @override
  Future<LoadingState> customGetData() async {
    final result = await (dialog != null
        ? (appRead(replyRepositoryProvider)).dialogList(
            type: replyType,
            oid: oid,
            root: rpid,
            dialog: dialog!,
            offset: paginationReply?.nextOffset,
          )
        : (appRead(replyRepositoryProvider)).detailList(
            type: replyType,
            oid: oid,
            root: rpid,
            rpid: id ?? 0,
            mode: mode,
            offset: paginationReply?.nextOffset,
          ));
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<void> onReload() {
    if (loadingState.isSuccess) {
      index = null;
    }
    return super.onReload();
  }

  @override
  void onReply(
    ReplyInfo? replyItem, {
    int? oid,
    int? replyType,
    int? index,
  }) {
    assert(replyItem != null && index != null);

    final (bool inputDisable, String? hint) = replyHint;
    if (inputDisable) {
      return;
    }

    final oid = replyItem!.oid.toInt();
    final root = replyItem.id.toInt();
    final key = oid + root;

    AppNavigator.push(
          PublishRoute(
            pageBuilder: (buildContext, animation, secondaryAnimation) {
              return ReplyPage(
                hint: hint,
                oid: oid,
                root: root,
                parent: root,
                replyType: this.replyType,
                replyItem: replyItem,
                items: savedReplies[key],
                onSave: (reply) {
                  if (reply.isEmpty) {
                    savedReplies.remove(key);
                  } else {
                    savedReplies[key] = reply.toList();
                  }
                },
              );
            },
          ),
        )
        ?.then((replyInfo) {
          if (replyInfo is ReplyInfo) {
            savedReplies.remove(key);

            count += 1;
            loadingState.dataOrNull?.insert(index! + 1, replyInfo);
            notifyListeners();
            if (enableCommAntifraud) {
              onCheckReply(replyInfo, isManual: false);
            }
          }
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _tickerProvider.dispose();
    super.dispose();
  }
}

class _TickerProvider implements TickerProvider {
  final List<Ticker> _tickers = [];

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick);
    _tickers.add(ticker);
    return ticker;
  }

  void dispose() {
    for (final ticker in _tickers) {
      ticker.dispose();
    }
    _tickers.clear();
  }
}
