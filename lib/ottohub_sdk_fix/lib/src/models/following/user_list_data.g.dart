// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserListData _$UserListDataFromJson(Map<String, dynamic> json) => UserListData(
  userList: (json['user_list'] as List<dynamic>)
      .map((e) => FollowingUser.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserListDataToJson(UserListData instance) =>
    <String, dynamic>{
      'user_list': instance.userList.map((e) => e.toJson()).toList(),
    };
