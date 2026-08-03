import 'package:json_annotation/json_annotation.dart';
import 'following_user.dart';

part 'user_list_data.g.dart';

/// 用户列表响应（关注列表等）。
@JsonSerializable(fieldRename: FieldRename.snake)
class UserListData {
  final List<FollowingUser> userList;

  const UserListData({
    required this.userList,
  });

  factory UserListData.fromJson(Map<String, dynamic> json) =>
      _$UserListDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserListDataToJson(this);
}
