import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/models/ui/multi_select_data.dart';

/// 下载页分页聚合模型：按 pageId 聚合的已缓存条目组。
class DownloadPageInfo with MultiSelectData {
  final String pageId;
  final String dirPath;
  final String title;
  String cover;
  int sortKey;
  final int? seasonType;
  final List<CoreDownloadEntryInfo> entries;

  DownloadPageInfo({
    required this.pageId,
    required this.dirPath,
    required this.title,
    required this.cover,
    required this.sortKey,
    this.seasonType,
    required this.entries,
  });
}
