import 'package:skf/common/widgets/flutter/text_field/controller.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/reply_types.dart' show CoreMode, CoreMainListReply;
import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show CursorReply, ReplyInfo, SubjectControl;
import 'package:skf/adapters/bilibili/grpc/bilibili/pagination.pb.dart' show FeedPaginationReply;
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/pages/common/publish/publish_route.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/reply_new/view.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/adapters/bilibili/utils/bili_storage_pref.dart';
import 'package:skf/adapters/bilibili/utils/reply_utils.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/router/app_navigator.dart';

abstract class ReplyController<R>
    extends CommonListControllerRiverpod<R, ReplyInfo> {
  ReplyController() {
    final cacheSortType = BiliPref.replySortType;
    sortType = cacheSortType;
    mode = cacheSortType == ReplySortType.time ? CoreMode.mainListTime : CoreMode.mainListHot;
  }
  int count = -1;

  late ReplySortType sortType;
  late CoreMode mode;

  final savedReplies = <Object, List<RichTextItem>?>{};

  Int64? upMid;
  int? cursorNext;
  SubjectControl? subjectControl;
  FeedPaginationReply? paginationReply;
  late bool hasUpTop = false;

  @override
  bool? get hasFooter => true;

  // comment antifraud
  late final _enableCommAntifraud = Pref.enableCommAntifraud;
  late final _biliSendCommAntifraud = BiliPref.biliSendCommAntifraud;
  bool get enableCommAntifraud =>
      _enableCommAntifraud || _biliSendCommAntifraud;
  dynamic get sourceId;


  @override
  void checkIsEnd(int length) {
    final count = this.count;
    if (count != -1 && length >= count) {
      isEnd = true;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<R> response) {
    final CoreMainListReply data;
    switch (response.response) {
      case final CoreMainListReply core:
        data = core;
      default:
        return false;
    }
    final cursor = data.cursor as CursorReply?;
    cursorNext = cursor?.next.toInt();
    paginationReply = data.paginationReply as FeedPaginationReply?;
    final subjectControl = data.subjectControl as SubjectControl?;
    count = subjectControl?.count.toInt() ?? 0;
    if (isRefresh) {
      this.subjectControl = subjectControl;
      upMid ??= subjectControl?.upMid;
      if (hasUpTop = data.hasUpTop()) {
        (data.replies as List<ReplyInfo>).insert(0, data.upTop as ReplyInfo);
      }
      if (subjectControl?.title == ReplySortType.select.title) {
        sortType = .select;
      }
    }
    isEnd = cursor?.isEnd ?? false;
    return false;
  }

  @override
  Future<void> onRefresh() {
    cursorNext = null;
    subjectControl = null;
    paginationReply = null;
    return super.onRefresh();
  }

  // 排序搜索评论
  void queryBySort() {
    if (isLoading) return;
    switch (sortType) {
      case ReplySortType.time:
        sortType = ReplySortType.hot;
        mode = CoreMode.mainListHot;
        break;
      case ReplySortType.hot:
        sortType = ReplySortType.time;
        mode = CoreMode.mainListTime;
        break;
      case ReplySortType.select:
        return;
    }
    feedBack();
    onReload();
  }

  (bool inputDisable, String? hint) get replyHint {
    String? hint;
    bool inputDisable = false;
    try {
      if (subjectControl case final subjectControl?) {
        inputDisable = subjectControl.inputDisable;
        if (subjectControl.hasRootText()) {
          final rootText = subjectControl.rootText;
          if (inputDisable) {
            SmartDialog.showToast(rootText);
          }
          if (rootText.contains('可发') || rootText.contains('可见')) {
            hint = rootText;
          }
        }
      }
    } catch (_) {}
    return (inputDisable, hint);
  }

  void onReply(
    ReplyInfo? replyItem, {
    int? oid,
    int? replyType,
  }) {
    if (loadingState case Error(:final errMsg, :final code)) {
      if (errMsg != null && (code == 12061 || code == 12002)) {
        SmartDialog.showToast(errMsg);
        return;
      }
    }

    assert(replyItem != null || (oid != null && replyType != null));

    final (bool inputDisable, String? hint) = replyHint;
    if (inputDisable) {
      return;
    }

    final key = oid ?? replyItem!.oid + replyItem.id;
    AppNavigator.push(
          PublishRoute(
            pageBuilder: (buildContext, animation, secondaryAnimation) {
              return ReplyPage(
                hint: hint,
                oid: oid ?? replyItem!.oid.toInt(),
                root: oid != null ? 0 : replyItem!.id.toInt(),
                parent: oid != null ? 0 : replyItem!.id.toInt(),
                replyType: replyItem?.type.toInt() ?? replyType!,
                replyItem: replyItem,
                items: savedReplies[key],

                /// hd api deprecated
                // canUploadPic: canUploadPic,
                onSave: (reply) {
                  if (reply.isEmpty) {
                    savedReplies.remove(key);
                  } else {
                    savedReplies[key] = reply.toList();
                  }
                },
              );
            },
            settings: RouteSettings(arguments: AppNavigator.arguments),
          ),
        )
        ?.then(
          (replyInfo) {
            if (replyInfo is ReplyInfo) {
              savedReplies.remove(key);
              if (loadingState case Success(:final response)) {
                if (response == null) {
                  loadingState = Success([replyInfo]);
                } else {
                  if (oid != null) {
                    response.insert(hasUpTop ? 1 : 0, replyInfo);
                  } else {
                    replyItem!
                      ..count += 1
                      ..replies.add(replyInfo);
                  }
                  notifyListeners();
                }
              } else {
                loadingState = Success([replyInfo]);
              }
              count += 1;

              // check reply
              if (enableCommAntifraud) {
                onCheckReply(replyInfo, isManual: false);
              }
            }
          },
        );
  }

  void onRemove(int index, ReplyInfo item, int? subIndex) {
    if (subIndex == null) {
      loadingState.data!.removeAt(index);
    } else {
      item
        ..count -= 1
        ..replies.removeAt(subIndex);
    }
    count -= 1;
    notifyListeners();
  }

  void onCheckReply(ReplyInfo replyInfo, {required bool isManual}) {
    ReplyUtils.onCheckReply(
      replyInfo: replyInfo,
      biliSendCommAntifraud: _biliSendCommAntifraud,
      sourceId: sourceId,
      isManual: isManual,
    );
  }

  Future<void> onToggleTop(
    ReplyInfo item,
    int index,
    oid,
    int type,
  ) async {
    bool isUpTop = item.replyControl.isUpTop;
    final res = await (appRead(replyRepositoryProvider)).replyTop(
      oid: oid,
      type: type,
      rpid: item.id.toString(),
      isUpTop: isUpTop,
    );
    if (res.isSuccess) {
      item.replyControl.isUpTop = !isUpTop;
      if (!isUpTop && index != 0) {
        final list = loadingState.data!;
        list
          ..first.replyControl.isUpTop = false
          ..insert(0, list.removeAt(index));
      }
      notifyListeners();
      SmartDialog.showToast('置顶成功');
    } else {
      res.toast();
    }
  }

  @override
  void dispose() {
    savedReplies.clear();
    super.dispose();
  }
}