import 'package:skf/pages/zone/zone_host.dart';

/// OttoHub 分区清单。
///
/// 分区 id 是站点魔法数字(0–7;2 由服务端重定向到 1,不单列)。
/// **官方未公布名称表**:SDK 文档仅确认 0=动画,其余名称按各分区内容
/// 抽样推断(1≈鬼畜、3≈音乐、4≈影视、5≈游戏、6≈综合、7≈娱乐)。
/// 如与站点实际分区名不符,直接修改本清单即可。
class OttoZoneHost implements ZoneHost {
  @override
  List<ZoneCategory> get categories => const [
        ZoneCategory(id: 0, label: '动画'),
        ZoneCategory(id: 1, label: '鬼畜'),
        ZoneCategory(id: 3, label: '音乐'),
        ZoneCategory(id: 4, label: '影视'),
        ZoneCategory(id: 5, label: '游戏'),
        ZoneCategory(id: 6, label: '综合'),
        ZoneCategory(id: 7, label: '娱乐'),
      ];
}
