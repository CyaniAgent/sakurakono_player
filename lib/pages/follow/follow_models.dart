/// Follow-domain local models & helpers (adapter-independent).
///
/// Copied from the bilibili adapter (`models/common/follow_order_type.dart`
/// `FollowOrderType` and `pages/share/view.dart` `UserModel`) so the migrated
/// pages keep zero adapter imports. The adapter copies stay for remaining
/// adapter call sites (bili_storage_pref, share panel, contact page).
library;

/// Follow list sort order.
enum FollowOrderType {
  def('', '最近关注'),
  attention('attention', '最常访问'),
  ;

  final String type;
  final String title;

  const FollowOrderType(this.type, this.title);
}

/// User picker callback payload (mid/name/avatar + selected flag).
class UserModel {
  UserModel({
    required this.mid,
    required this.name,
    required this.avatar,
    this.selected = false,
  });

  final int mid;
  final String name;
  final String avatar;
  bool selected;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is UserModel) {
      return mid == other.mid;
    }
    return false;
  }

  @override
  int get hashCode => mid.hashCode;
}

/// Whether a tag id is a user-created (custom) follow group.
///
/// Mirrors `BiliUtils.isCustomFollowTag` from the bilibili adapter.
bool isCustomFollowTag(int? tagid) =>
    tagid != null && tagid != 0 && tagid != -10 && tagid != -2;

/// Extracts `official_verify.type` from a core follow item payload.
///
/// Mirrors `ModelConverters.followItem` semantics: raw JSON maps are
/// handled, any non-map payload (e.g. `0` from legacy APIs) is null.
int? coreOfficialVerifyType(dynamic officialVerify) => officialVerify is Map
    ? officialVerify['type'] as int?
    : null;
