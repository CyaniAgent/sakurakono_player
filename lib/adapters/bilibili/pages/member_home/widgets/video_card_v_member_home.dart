import 'package:skf/common/style.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/common/widgets/badge.dart';
import 'package:skf/adapters/bilibili/common/widgets/image/image_save.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/models/ui/badge_type.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_archive/item.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/dimension.dart';
import 'package:skf/adapters/bilibili/utils/app_scheme.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:flutter/material.dart';

// 视频卡片 - 垂直布局
class VideoCardVMemberHome extends StatelessWidget {
  final SpaceArchiveItem videoItem;

  const VideoCardVMemberHome({
    super.key,
    required this.videoItem,
  });

  Future<void> onPushDetail() async {
    String? goto = videoItem.goto;
    switch (goto) {
      case 'bangumi':
        PageUtils.viewPgc(epId: videoItem.param);
        break;

      case 'av':
        if (videoItem.isPgc == true) {
          if (videoItem.uri?.isNotEmpty == true) {
            PageUtils.viewPgcFromUri(videoItem.uri!);
          }
          return;
        }

        String? aid = videoItem.param;
        String? bvid = videoItem.bvid;
        if (aid == null && bvid == null) {
          return;
        }

        bvid ??= IdUtils.av2bv(int.parse(aid!));
        int? cid = videoItem.cid;
        Dimension? dimension;
        if (cid == null) {
          if (await appRead(searchRepositoryProvider).ab2cWithDimension(
                aid: int.tryParse(aid ?? ''),
                bvid: bvid,
              )
              case final res?) {
            cid = res.cid;
            dimension = ModelConverters.dimension(res.dimension);
          }
        }
        if (cid != null) {
          PageUtils.toVideoPage(
            bvid: bvid,
            cid: cid,
            cover: videoItem.cover,
            title: videoItem.title,
            dimension: dimension,
          );
        }
        break;

      default:
        if (videoItem.uri?.isNotEmpty == true) {
          PiliScheme.routePushFromUrl(videoItem.uri!);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    void onLongPress() => imageSaveDialog(
      title: videoItem.title,
      cover: videoItem.cover,
      aid: videoItem.param,
      bvid: videoItem.bvid,
    );
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPushDetail,
        onLongPress: onLongPress,
        onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: Style.aspectRatio,
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
                  double maxWidth = boxConstraints.maxWidth;
                  double maxHeight = boxConstraints.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NetworkImgLayer(
                        src: videoItem.cover,
                        width: maxWidth,
                        height: maxHeight,
                        type: .emote,
                      ),
                      if (videoItem.duration > 0)
                        PBadge(
                          bottom: 6,
                          right: 7,
                          size: CorePBadgeSize.small,
                          type: CorePBadgeType.gray,
                          text: DurationUtils.formatDuration(
                            videoItem.duration,
                          ),
                        ),
                      if (videoItem.badges?.isNotEmpty == true)
                        PBadge(
                          text: videoItem.badges!
                              .map((e) => e.text ?? '')
                              .join('|'),
                          top: 6,
                          right: 6,
                          type: videoItem.badges!.first.text == '充电专属'
                              ? CorePBadgeType.error
                              : CorePBadgeType.primary,
                        )
                      else if (videoItem.isCooperation == true)
                        const PBadge(
                          text: '合作',
                          top: 6,
                          right: 6,
                        )
                      else if (videoItem.isSteins == true)
                        const PBadge(
                          text: '互动',
                          top: 6,
                          right: 6,
                        ),
                    ],
                  );
                },
              ),
            ),
            content(context),
          ],
        ),
      ),
    );
  }

  Widget content(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
        child: Text(
          '${videoItem.title}\n',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            height: 1.38,
          ),
        ),
      ),
    );
  }
}
