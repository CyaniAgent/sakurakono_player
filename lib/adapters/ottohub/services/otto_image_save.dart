// OttoHub 视频封面保存弹窗。
//
// 复原原 imageSaveDialog(bb7d917 快照)版式:大图预览(点击关闭)+
// 标题行(长按可选中文字)+ 操作行(复制链接/保存封面/分享,经
// 框架层 ImageUtils)。OttoHub 无「稍后再看」概念,不提供该入口。

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:skf/common/style.dart';
import 'package:skf/common/widgets/button/icon_button.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/common/widgets/selection_text.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/image_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/utils.dart';

void ottoImageSaveDialog({
  required String? title,
  required String? cover,
  String? videoId,
}) {
  final double imgWidth =
      MediaQuery.sizeOf(AppNavigator.context!).shortestSide - 16;
  SmartDialog.show(
    animationType: SmartAnimationType.centerScale_otherSlide,
    builder: (context) {
      const iconSize = 20.0;
      final theme = Theme.of(context);
      return Container(
        width: imgWidth,
        margin: const EdgeInsets.symmetric(horizontal: Style.safeSpace),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: Style.mdRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: SmartDialog.dismiss,
                  child: NetworkImgLayer(
                    src: cover,
                    quality: 100,
                    width: imgWidth,
                    height: imgWidth / Style.aspectRatio16x9,
                    borderRadius: const BorderRadius.vertical(
                      top: Style.imgRadius,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  width: 30,
                  height: 30,
                  child: IconButton(
                    tooltip: '关闭',
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                    ),
                    onPressed: SmartDialog.dismiss,
                    icon: const Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: SelectionText(title, style: theme.textTheme.titleSmall),
                    )
                  else
                    const Spacer(),
                  if (videoId != null)
                    iconButton(
                      iconSize: iconSize,
                      tooltip: '复制视频链接',
                      onPressed: () {
                        SmartDialog.dismiss();
                        Utils.copyText(
                          'https://www.ottohub.cn/video/$videoId',
                        );
                      },
                      icon: const Icon(Icons.link),
                    ),
                  if (cover != null && cover.isNotEmpty) ...[
                    if (PlatformUtils.isMobile)
                      iconButton(
                        iconSize: iconSize,
                        tooltip: '分享',
                        onPressed: () {
                          SmartDialog.dismiss();
                          ImageUtils.onShareImg(cover);
                        },
                        icon: const Icon(Icons.share),
                      ),
                    iconButton(
                      iconSize: iconSize,
                      tooltip: '保存封面图',
                      onPressed: () async {
                        bool saveStatus = await ImageUtils.downloadImg([cover]);
                        if (saveStatus) {
                          SmartDialog.dismiss();
                        }
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
