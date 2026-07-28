/// Core blacklist item model — adapter-independent.
class CoreBlackListItem {
  int? mid;
  int? mtime;
  String? uname;
  String? face;

  CoreBlackListItem({
    this.mid,
    this.mtime,
    this.uname,
    this.face,
  });

  factory CoreBlackListItem.fromJson(Map<String, dynamic> json) => CoreBlackListItem(
    mid: json['mid'] as int?,
    mtime: json['mtime'] as int?,
    uname: json['uname'] as String?,
    face: json['face'] as String?,
  );
}
