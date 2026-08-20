import 'dart:math';
import 'package:skf/router/app_navigator.dart';

import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/button/more_btn.dart';
import 'package:skf/common/widgets/loading_widget/loading_widget.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/tab2.dart';
import 'package:skf/pages/member/controller.dart';
import 'package:skf/adapters/bilibili/pages/member_article/widget/item.dart';
import 'package:skf/adapters/bilibili/pages/member_audio/widgets/item.dart';
import 'package:skf/adapters/bilibili/pages/member_coin_arc/view.dart';
import 'package:skf/adapters/bilibili/pages/member_comic/widgets/item.dart';
import 'package:skf/adapters/bilibili/pages/member_home/widgets/fav_item.dart';
import 'package:skf/adapters/bilibili/pages/member_home/widgets/video_card_v_member_home.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/adapters/bilibili/pages/member_like_arc/view.dart';
import 'package:skf/adapters/bilibili/pages/member_pgc/widgets/pgc_card_v_member_pgc.dart';
import 'package:skf/utils/extension/context_ext.dart';
import 'package:skf/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class MemberHome extends StatefulWidget {
  const MemberHome({super.key, this.heroTag});

  final String? heroTag;

  @override
  State<MemberHome> createState() => _MemberHomeState();
}

class _MemberHomeState extends State<MemberHome>
    with AutomaticKeepAliveClientMixin, GridMixin {
  @override
  bool get wantKeepAlive => true;

  late final _ctr = Get.find<MemberController>(tag: widget.heroTag);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildBody(_ctr.loadingState.value);
  }

  late final gridDelegateV = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: Style.cardSpace,
    crossAxisSpacing: Style.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth,
    childAspectRatio: Style.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(55),
  );

  late final gridDelegateAudio = Grid.videoCardHDelegate();

  late final gridDelegatePgc = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: Style.cardSpace,
    crossAxisSpacing: Style.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth * 0.6,
    childAspectRatio: 0.75,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(52),
  );

  Widget _buildBody(LoadingState<CoreSpaceData?> loadingState) {
    final isVertical = context.width < 600;
    final setting = _ctr.spaceSetting;
    final isOwner = setting != null;
    final color = Theme.of(context).colorScheme.outline;
    return switch (loadingState) {
      Loading() => m3eLoading,
      Success(response: final res) =>
        res != null
            ? CustomScrollView(
                slivers: [
                  if (res.coreArchive?.item?.isNotEmpty == true) ...[
                    _header(
                      color,
                      title: '视频',
                      param: 'contribute',
                      param1: 'video',
                      count: res.coreArchive!.count!,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Style.safeSpace,
                      ),
                      sliver: SliverGrid.builder(
                        gridDelegate: gridDelegateV,
                        itemBuilder: (context, index) {
                          return VideoCardVMemberHome(
                            videoItem: ModelConverters.archiveItem(
                              res.coreArchive!.item![index],
                            ),
                          );
                        },
                        itemCount: min(
                          isVertical ? 4 : 8,
                          res.coreArchive!.item!.length,
                        ),
                      ),
                    ),
                  ],
                  if (res.coreFavourite2?.item?.isNotEmpty == true) ...[
                    _header(
                      color,
                      title: '收藏',
                      param: 'favorite',
                      count: res.coreFavourite2!.count!,
                      visible: isOwner ? setting.favVideo == 1 : null,
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 110,
                        child: MemberFavItem(
                          item: ModelConverters.favouriteItem(
                            res.coreFavourite2!.item!.first,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (res.coreCoinArchive?.item?.isNotEmpty == true) ...[
                    _header(
                      color,
                      title: '最近投币的视频',
                      param: 'coinArchive',
                      count: res.coreCoinArchive!.count!,
                      visible: isOwner ? setting.coinsVideo == 1 : null,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Style.safeSpace,
                      ),
                      sliver: SliverGrid.builder(
                        gridDelegate: gridDelegateV,
                        itemBuilder: (context, index) {
                          return VideoCardVMemberHome(
                            videoItem: ModelConverters.coinLikeItem(
                              res.coreCoinArchive!.item![index],
                            ),
                          );
                        },
                        itemCount: min(
                          isVertical ? 2 : 4,
                          res.coreCoinArchive!.item!.length,
                        ),
                      ),
                    ),
                  ],
                  if (res.coreLikeArchive?.item?.isNotEmpty == true) ...[
                    _header(
                      color,
                      title: '最近点赞的视频',
                      param: 'likeArchive',
                      count: res.coreLikeArchive!.count!,
                      visible: isOwner ? setting.likesVideo == 1 : null,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Style.safeSpace,
                      ),
                      sliver: SliverGrid.builder(
                        gridDelegate: gridDelegateV,
                        itemBuilder: (context, index) {
                          return VideoCardVMemberHome(
                            videoItem: ModelConverters.likeArchiveItem(
                              res.coreLikeArchive!.item![index],
                            ),
                          );
                        },
                        itemCount: min(
                          isVertical ? 2 : 4,
                          res.coreLikeArchive!.item!.length,
                        ),
                      ),
                    ),
                  ],
                  if (res.coreArticle?.item?.isNotEmpty == true) ...[
                    _header(
                      color,
                      title: '图文',
                      param: 'contribute',
                      param1: 'opus',
                      count: res.coreArticle!.count!,
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 110,
                        child: MemberArticleItem(
                          item: ModelConverters.articleItem(
                            res.coreArticle!.item!.first,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (res.coreAudios?.item?.isNotEmpty == true) ...[
                    _header(
                      color,
                      title: '音频',
                      param: 'contribute',
                      param1: 'audio',
                      count: res.coreAudios!.count!,
                    ),
                    SliverGrid.builder(
                      gridDelegate: gridDelegateAudio,
                      itemBuilder: (context, index) {
                        return MemberAudioItem(
                          item: ModelConverters.audioItem(
                            res.coreAudios!.item![index],
                          ),
                        );
                      },
                      itemCount: isVertical ? 1 : min(3, res.coreAudios!.count!),
                    ),
                  ],
                  if (res.coreComic?.item?.isNotEmpty == true) ...[
                    _header(
                      color,
                      title: '漫画',
                      param: 'contribute',
                      param1: 'comic',
                      count: res.coreComic!.count!,
                    ),
                    SliverGrid.builder(
                      gridDelegate: gridDelegate,
                      itemBuilder: (context, index) {
                        return MemberComicItem(
                          item: ModelConverters.comicItem(
                            res.coreComic!.item![index],
                          ),
                        );
                      },
                      itemCount: isVertical ? 1 : min(3, res.coreComic!.count!),
                    ),
                  ],
                  if (res.season?.item?.isNotEmpty == true) ...[
                    _header(
                      color,
                      title: '追番',
                      param: 'bangumi',
                      count: res.season!.count!,
                      visible: isOwner ? setting.bangumi == 1 : null,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Style.safeSpace,
                      ),
                      sliver: SliverGrid.builder(
                        gridDelegate: gridDelegatePgc,
                        itemBuilder: (context, index) {
                          return PgcCardVMemberPgc(
                            item: ModelConverters.seasonItem(
                              res.season!.item![index],
                            ),
                          );
                        },
                        itemCount: min(
                          isVertical ? 3 : 6,
                          res.season!.item!.length,
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                  ),
                ],
              )
            : scrollableError,
      Error(:final errMsg) => scrollErrorWidget(errMsg: errMsg),
    };
  }

  Widget _header(
    Color color, {
    required String title,
    required String param,
    String? param1,
    required int count,
    bool? visible,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$title '),
                  TextSpan(
                    text: count.toString(),
                    style: TextStyle(fontSize: 13, color: color),
                  ),
                  if (visible != null)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          visible ? Icons.visibility : Icons.visibility_off,
                          size: 17,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            moreTextButton(
              onTap: () {
                int index = _ctr.tab2!.indexWhere(
                  (item) => item.param == param,
                );
                if (index != -1) {
                  if (const [
                    'video',
                    'opus',
                    'audio',
                    'comic',
                  ].contains(param1)) {
                    List<SpaceTab2Item> items = _ctr.tab2!
                        .firstWhere((item) => item.param == param)
                        .items! as List<SpaceTab2Item>;
                    int index1 = items.indexWhere(
                      (item) => item.param == param1,
                    );
                    if (index1 != -1) {
                      _ctr.contributeInitialIndex.value = index1;
                    }
                  }
                  _ctr.tabController?.animateTo(index);
                } else {
                  if (param == 'coinArchive') {
                    AppNavigator.to(
                      MemberCoinArcPage(
                        mid: _ctr.mid,
                        name: _ctr.username,
                      ),
                    );
                    return;
                  }

                  if (param == 'likeArchive') {
                    AppNavigator.to(
                      MemberLikeArcPage(
                        mid: _ctr.mid,
                        name: _ctr.username,
                      ),
                    );
                    return;
                  }

                  // NOTE: unhandled contribute params fall back to a toast.
                  SmartDialog.showToast('view $param');
                }
              },
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
