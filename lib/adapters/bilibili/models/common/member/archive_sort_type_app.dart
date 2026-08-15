import 'package:skf/player/models/enum_with_label.dart';

enum ArchiveSortTypeApp with EnumWithLabel {
  desc('默认'),
  asc('倒序'),
  ;

  @override
  final String label;
  const ArchiveSortTypeApp(this.label);
}
