import 'package:skf/player/models/enum_with_label.dart';

enum ArchiveOrderTypeApp with EnumWithLabel {
  pubdate('最新发布'),
  click('最多播放'),
  ;

  @override
  final String label;
  const ArchiveOrderTypeApp(this.label);
}
