/// Follow-domain action helpers — ported from the bilibili adapter's
/// `RequestUtils` (`actionRelationMod` / `createFavTag`) onto core
/// repositories. The adapter originals stay for remaining adapter call
/// sites (video page, member page, group panel).
library;

import 'dart:math';
import 'package:skf/core/container/app_container.dart';

import 'package:skf/common/widgets/dialog/dialog.dart';
import 'package:skf/common/widgets/dialog/simple_dialog_option.dart';
import 'package:skf/core/models/user_types.dart' show CoreRelationData;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/follow/widgets/follow_tag_panel.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/extension/context_ext.dart';
import 'package:skf/utils/extension/size_ext.dart';
import 'package:skf/utils/feed_back.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

abstract final class FollowActions {
  /// Create a follow tag group via a name-input dialog.
  static Future<void> createFavTag(
    BuildContext context,
    ValueChanged<({int tagid, String tagName})> onSuccess,
  {Ref? ref}) async {
    String tagName = '';
    final onCreate = await showConfirmDialog(
      context: context,
      title: const Text('新建分组'),
      content: TextFormField(
        autofocus: true,
        initialValue: tagName,
        onChanged: (value) => tagName = value,
        inputFormatters: [
          LengthLimitingTextInputFormatter(16),
        ],
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
    if (onCreate) {
      final res = await (ref?.read(memberRepositoryProvider) ?? appRead(memberRepositoryProvider)).createFollowTag(tagName);
      if (res case Success(:final response)) {
        onSuccess((tagid: response, tagName: tagName));
        SmartDialog.showToast('创建成功');
      } else {
        res.toast();
      }
    }
  }

  /// Follow / unfollow / special-follow / group-set dialog flow.
  static Future<void> actionRelationMod({
    required BuildContext context,
    required int mid,
    required bool isFollow,
    required ValueChanged<int>? afterMod,
    CoreRelationData? followStatus,
    Ref? ref,
  }) async {
    feedBack();
    if (!isFollow) {
      final res = await (ref?.read(videoRepositoryProvider) ?? appRead(videoRepositoryProvider)).relationMod(
        mid: mid,
        act: 1,
        reSrc: 11,
      );
      if (res.isSuccess) {
        SmartDialog.showToast('关注成功');
        afterMod?.call(2);
      } else {
        res.toast();
      }
    } else {
      if (followStatus?.tag == null) {
        final res = await (ref?.read(userRepositoryProvider) ?? appRead(userRepositoryProvider)).userRelation(mid);
        if (res case Success(:final response)) {
          followStatus = response;
        } else {
          res.toast();
          return;
        }
      }

      if (context.mounted) {
        bool isSpecialFollowed = followStatus!.special == 1;
        String text = isSpecialFollowed ? '移除特别关注' : '加入特别关注';
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            clipBehavior: Clip.hardEdge,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              DialogOption(
                onPressed: () async {
                  AppNavigator.back();
                  final res = await (ref?.read(memberRepositoryProvider) ?? appRead(memberRepositoryProvider)).specialAction(
                    fid: mid,
                    isAdd: !isSpecialFollowed,
                  );
                  if (res.isSuccess) {
                    SmartDialog.showToast('$text成功');
                    afterMod?.call(isSpecialFollowed ? 2 : -10);
                  } else {
                    res.toast();
                  }
                },
                child: Text(text, style: const TextStyle(fontSize: 14)),
              ),
              DialogOption(
                onPressed: () async {
                  AppNavigator.back();
                  final result = await showModalBottomSheet<Set<int>>(
                    context: context,
                    useSafeArea: true,
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      maxWidth: min(640, context.mediaQueryShortestSide),
                    ),
                    builder: (BuildContext context) {
                      final maxChildSize =
                          PlatformUtils.isMobile &&
                              !context.mediaQuerySize.isPortrait
                          ? 1.0
                          : 0.7;
                      return DraggableScrollableSheet(
                        minChildSize: 0,
                        maxChildSize: 1,
                        snap: true,
                        expand: false,
                        snapSizes: [maxChildSize],
                        initialChildSize: maxChildSize,
                        builder: (context, scrollController) {
                          return FollowTagPanel(
                            mid: mid,
                            tags: followStatus!.tag,
                            scrollController: scrollController,
                          );
                        },
                      );
                    },
                  );
                  if (result != null) {
                    followStatus!.tag = result.toList();
                    afterMod?.call(result.contains(-10) ? -10 : 2);
                  }
                },
                child: const Text('设置分组', style: TextStyle(fontSize: 14)),
              ),
              DialogOption(
                onPressed: () async {
                  AppNavigator.back();
                  final res = await (ref?.read(videoRepositoryProvider) ?? appRead(videoRepositoryProvider)).relationMod(
                    mid: mid,
                    act: 2,
                    reSrc: 11,
                  );
                  if (res.isSuccess) {
                    SmartDialog.showToast('取消关注成功');
                    afterMod?.call(0);
                  } else {
                    res.toast();
                  }
                },
                child: const Text('取消关注', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        );
      }
    }
  }
}
