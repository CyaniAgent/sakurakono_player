import 'package:skf/core/container/app_container.dart';
import 'package:skf/pages/providers.dart';

/// 视频分区条目:分区体系由适配器定义(站点分类/频道皆是),
/// [id] 的语义由适配器的 [VideoRepository.categoryVideoList] 实现解释。
class ZoneCategory {
  const ZoneCategory({required this.id, required this.label});

  /// 分区 id(适配器自定义语义)。
  final int id;

  /// 展示名。
  final String label;
}

/// Adapter-provided catalog for the generic zone (categories) page.
///
/// 首页「分区」子 tab 的分类清单由激活适配器提供;清单为空时页面显示占位。
abstract class ZoneHost {
  static ZoneHost of() => appRead(zoneHostProvider);

  /// 分区清单(顺序即展示顺序)。
  List<ZoneCategory> get categories;
}
