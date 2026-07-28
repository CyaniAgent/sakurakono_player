/// Core follow item model — adapter-independent.
///
/// Standalone model with commonly-used fields. Does not extend [UpItem] so
/// it can be used across adapters without importing adapter internals.
class CoreFollowItemModel {
  int mid;
  String? uname;
  String? face;
  int? attribute;
  String? sign;
  dynamic officialVerify;

  CoreFollowItemModel({
    this.mid = 0,
    this.uname,
    this.face,
    this.attribute,
    this.sign,
    this.officialVerify,
  });

  factory CoreFollowItemModel.fromJson(Map<String, dynamic> json) =>
      CoreFollowItemModel(
        mid: json['mid'] as int? ?? 0,
        uname: json['uname'] as String?,
        face: json['face'] as String?,
        attribute: json['attribute'] as int?,
        sign: json['sign'] as String?,
        officialVerify: json['official_verify'],
      );
}
