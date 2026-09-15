import 'package:skf/common/widgets/self_sized_horizontal_list.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/common/widgets/sliver/sliver_pinned_header.dart';
import 'package:skf/adapters/bilibili/models/common/member/archive_order_type_web.dart';
import 'package:skf/adapters/bilibili/models_new/member/search_archive/data.dart';
import 'package:skf/adapters/bilibili/models_new/member/search_archive/vlist.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/archive/controller.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/base/controller.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/base/view.dart';
import 'package:skf/pages/search/widgets/search_text.dart';
import 'package:flutter/material.dart';

class MemberVideoWeb extends StatefulWidget {
  const MemberVideoWeb({super.key});

  @override
  State<MemberVideoWeb> createState() => _MemberVideoWebState();

  static Future<void>? toMemberVideoWeb({
    required Object mid,
    required String name,
  }) {
    return AppNavigator.toNamed(
      '/videoWeb',
      arguments: {
        'mid': mid,
        'name': name,
      },
    );
  }
}

class _MemberVideoWebState
    extends
        BaseVideoWebState<
          MemberVideoWeb,
          SearchArchiveData,
          VListItemModel,
          ArchiveOrderTypeWeb
        > {
  late final MemberVideoWebCtr _webCtr = MemberVideoWebCtr();

  @override
  BaseVideoWebCtr<SearchArchiveData, VListItemModel, ArchiveOrderTypeWeb> get controller =>
      _webCtr as BaseVideoWebCtr<SearchArchiveData, VListItemModel, ArchiveOrderTypeWeb>;


  @override
  List<ArchiveOrderTypeWeb> get values => ArchiveOrderTypeWeb.values;

  @override
  Widget? buildTags(ColorScheme colorScheme) {
    if (_webCtr.tags case final tags?) {
      return SliverPinnedHeader(
        backgroundColor: colorScheme.surface,
        child: SelfSizedHorizontalList(
          itemCount: tags.length,
          padding: const .fromLTRB(10, 0, 10, 8),
          itemBuilder: (context, index) {
            final item = tags[index];
            final isCurr = _webCtr.specialType != null
                ? item.specialType == _webCtr.specialType
                : item.tid == _webCtr.tid;
            return SearchText(
              padding: const .symmetric(horizontal: 8, vertical: 4),
              text: '${item.name!} ${item.count}',
              bgColor: isCurr ? colorScheme.secondaryContainer : null,
              textColor: isCurr ? colorScheme.onSecondaryContainer : null,
              onTap: (_) {
                if (isCurr) return;
                _webCtr
                  ..tid = item.tid ?? 0
                  ..specialType = item.specialType
                  ..onReload();
              },
            );
          },
          separatorBuilder: (_, _) => const SizedBox(width: 10),
        ),
      );
    }
    return null;
  }
}
