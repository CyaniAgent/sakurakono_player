// OttoHub 视频卡片右下角弹出菜单。
//
// 复原原 VideoPopupMenu(bb7d917 快照)形态,菜单项按 OttoHub 能力
// 裁剪:复制视频链接、保存封面、访问UP主。(稍后再看/AI总结等
// 服务端无对应 API,维持降级。)

import 'package:flutter/material.dart';

import 'package:skf/adapters/ottohub/services/otto_image_save.dart';
import 'package:skf/common/widgets/custom_icon.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/utils.dart';

class OttoVideoPopupMenu extends StatelessWidget {
  final double? iconSize;

  /// 视频 ID(OttoHub 纯数字)。
  final String videoId;
  final String? title;
  final String? cover;

  /// UP 主 ID/名称(缺省时隐藏「访问UP主」)。
  final int? ownerId;
  final String? ownerName;

  const OttoVideoPopupMenu({
    super.key,
    required this.iconSize,
    required this.videoId,
    this.title,
    this.cover,
    this.ownerId,
    this.ownerName,
  });

  void _onSaveCover() {
    ottoImageSaveDialog(title: title, cover: cover, videoId: videoId);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_vert_outlined,
        color: Theme.of(context).colorScheme.outline,
        size: iconSize,
      ),
      position: PopupMenuPosition.under,
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          height: 45,
          onTap: () => Utils.copyText('https://www.ottohub.cn/video/$videoId'),
          child: const Row(
            children: [
              Icon(CustomIcons.identifier_circle, size: 16),
              SizedBox(width: 10),
              Text('复制视频链接'),
            ],
          ),
        ),
        if (cover?.isNotEmpty == true)
          PopupMenuItem<String>(
            height: 45,
            onTap: _onSaveCover,
            child: const Row(
              children: [
                Icon(Icons.download_outlined, size: 16),
                SizedBox(width: 10),
                Text('保存封面'),
              ],
            ),
          ),
        if (ownerId != null)
          PopupMenuItem<String>(
            height: 45,
            onTap: () => AppNavigator.toNamed('/member?mid=$ownerId'),
            child: Row(
              children: [
                const Icon(Icons.account_circle_outlined, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ownerName == null ? '访问UP主' : '访问：$ownerName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
