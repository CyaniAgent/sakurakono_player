import 'package:flutter/material.dart';
import 'package:skf/common/widgets/image/network_img_layer.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/router/app_navigator.dart';
import 'package:skf/utils/num_utils.dart';
import 'package:skf/utils/utils.dart';

/// 热门/分区列表通用竖版视频卡(封面 + 标题 + 播放数 + UP 主)。
class HotVideoCard extends StatelessWidget {
  const HotVideoCard({super.key, required this.item});

  final CoreHotVideoItemModel item;

  void _onTap() {
    AppNavigator.toNamed(
      '/videoV',
      preventDuplicates: false,
      arguments: <String, dynamic>{
        'aid': item.aid,
        'bvid': item.bvid,
        'cid': item.cid ?? 0,
        'cover': item.cover,
        'title': item.title,
        'heroTag': Utils.makeHeroTag(item.cid ?? item.aid),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Card(
      clipBehavior: .hardEdge,
      child: InkWell(
        onTap: _onTap,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: .expand,
                children: [
                  NetworkImgLayer(src: item.cover, width: 320, height: 180),
                  if ((item.duration ?? 0) > 0)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const .symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(item.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const .all(8),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title ?? '',
                        maxLines: 2,
                        overflow: .ellipsis,
                        style: const TextStyle(height: 1.3),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.slideshow,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          NumUtils.numFormat(
                            (item.stat?['view'] as int?) ?? 0,
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.owner?['name'] ?? '',
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
