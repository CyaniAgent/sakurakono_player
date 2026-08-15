/// 稍后再看列表的分类枚举（纯数据，无 UI 耦合）。
///
/// 页面由 view.dart 直接构建（携带导航契约），因此不提供 page getter。
enum LaterViewType {
  all(0, '全部'),
  // toView(1, '未看'),
  unfinished(2, '未看完'),
  // viewed(3, '已看完'),
  ;

  final int type;
  final String title;
  const LaterViewType(this.type, this.title);
}
