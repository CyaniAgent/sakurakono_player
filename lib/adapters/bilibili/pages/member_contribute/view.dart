import 'dart:math';

import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/member/controller.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/tab2.dart';
import 'package:skf/adapters/bilibili/pages/member_article/view.dart';
import 'package:skf/adapters/bilibili/pages/member_audio/view.dart';
import 'package:skf/adapters/bilibili/pages/member_comic/view.dart';
import 'package:skf/adapters/bilibili/pages/member_contribute/controller.dart';
import 'package:skf/adapters/bilibili/pages/member_opus/view.dart';
import 'package:skf/adapters/bilibili/pages/member_season_series/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video/view.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class MemberContribute extends ConsumerStatefulWidget {
  const MemberContribute({
    super.key,
    this.heroTag,
    this.initialIndex,
    required this.mid,
  });

  final String? heroTag;
  final int? initialIndex;
  final int mid;

  @override
  ConsumerState<MemberContribute> createState() => _MemberContributeState();
}

class _MemberContributeState extends ConsumerState<MemberContribute>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Read MemberController data and feed into the Riverpod notifier.
    try {
      final memberCtr = Get.find<MemberController>(tag: widget.heroTag);
      final contribute = memberCtr.tab2!.firstWhere(
        (item) => item.param == 'contribute',
      );
      if (contribute.items?.isNullOrEmpty == false) {
        ref
            .read(memberContributeProvider(widget.heroTag).notifier)
            .initData(
              contributeItems: contribute.items,
              hasSeasonOrSeries: memberCtr.hasSeasonOrSeries == true,
            );
      }
    } catch (_) {
      // MemberController not ready yet; state stays default.
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final state = ref.watch(memberContributeProvider(widget.heroTag));

    // Create / recreate TabController when tabs become available or change
    // length.  The controller lives here (with TickerProviderStateMixin)
    // because TabController requires a TickerProvider for vsync.
    if (state.tabs != null) {
      if (_tabController == null ||
          _tabController!.length != state.tabs!.length) {
        _tabController?.dispose();
        _tabController = TabController(
          vsync: this,
          length: state.tabs!.length,
          initialIndex: max(0, state.currentIndex),
        );
      }
    }

    return state.tabs != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                isScrollable: true,
                tabs: state.tabs!,
                tabAlignment: TabAlignment.start,
                controller: _tabController,
                dividerHeight: 0,
                indicatorWeight: 0,
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 8,
                ),
                indicator: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle:
                    TabBarTheme.of(
                      context,
                    ).labelStyle?.copyWith(fontSize: 14) ??
                    const TextStyle(fontSize: 14),
                labelColor: theme.colorScheme.onSecondaryContainer,
                unselectedLabelColor: theme.colorScheme.outline,
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: state.items!
                      .whereType<SpaceTab2Item>()
                      .map(_getPageFromType)
                      .toList(),
                ),
              ),
            ],
          )
        : state.items?.isNotEmpty == true
        ? _getPageFromType(state.items!.first as SpaceTab2Item)
        : scrollableError;
  }

  Widget _getPageFromType(SpaceTab2Item item) {
    final state = ref.watch(memberContributeProvider(widget.heroTag));
    final isSingle = state.tabs == null;
    return switch (item.param) {
      'video' => MemberVideo(
        type: CoreContributeType.video,
        heroTag: widget.heroTag,
        mid: widget.mid,
        title: item.title,
        isSingle: isSingle,
      ),
      'charging_video' => MemberVideo(
        type: CoreContributeType.charging,
        heroTag: widget.heroTag,
        mid: widget.mid,
        title: item.title,
      ),
      'article' => MemberArticle(
        heroTag: widget.heroTag,
        mid: widget.mid,
      ),
      'opus' => MemberOpus(
        heroTag: widget.heroTag,
        mid: widget.mid,
        isSingle: isSingle,
      ),
      'audio' => MemberAudio(
        heroTag: widget.heroTag,
        mid: widget.mid,
      ),
      'comic' => MemberComic(
        heroTag: widget.heroTag,
        mid: widget.mid,
      ),
      'season_video' => MemberVideo(
        type: CoreContributeType.season,
        heroTag: widget.heroTag,
        mid: widget.mid,
        seasonId: item.seasonId,
        title: item.title,
      ),
      'series' => MemberVideo(
        type: CoreContributeType.series,
        heroTag: widget.heroTag,
        mid: widget.mid,
        seriesId: item.seriesId?.toString(),
        title: item.title,
      ),
      'ugcSeason' => SeasonSeriesPage(
        mid: widget.mid,
        heroTag: widget.heroTag,
      ),
      _ => Center(child: Text(item.title!)),
    };
  }
}
