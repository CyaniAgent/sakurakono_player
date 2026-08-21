// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreActiveFollower {

 int get uid; String get username; String get avatarUrl; String get latestActivityTime;
/// Create a copy of CoreActiveFollower
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreActiveFollowerCopyWith<CoreActiveFollower> get copyWith => _$CoreActiveFollowerCopyWithImpl<CoreActiveFollower>(this as CoreActiveFollower, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreActiveFollower&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.latestActivityTime, latestActivityTime) || other.latestActivityTime == latestActivityTime));
}


@override
int get hashCode => Object.hash(runtimeType,uid,username,avatarUrl,latestActivityTime);

@override
String toString() {
  return 'CoreActiveFollower(uid: $uid, username: $username, avatarUrl: $avatarUrl, latestActivityTime: $latestActivityTime)';
}


}

/// @nodoc
abstract mixin class $CoreActiveFollowerCopyWith<$Res>  {
  factory $CoreActiveFollowerCopyWith(CoreActiveFollower value, $Res Function(CoreActiveFollower) _then) = _$CoreActiveFollowerCopyWithImpl;
@useResult
$Res call({
 int uid, String username, String avatarUrl, String latestActivityTime
});




}
/// @nodoc
class _$CoreActiveFollowerCopyWithImpl<$Res>
    implements $CoreActiveFollowerCopyWith<$Res> {
  _$CoreActiveFollowerCopyWithImpl(this._self, this._then);

  final CoreActiveFollower _self;
  final $Res Function(CoreActiveFollower) _then;

/// Create a copy of CoreActiveFollower
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? username = null,Object? avatarUrl = null,Object? latestActivityTime = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,latestActivityTime: null == latestActivityTime ? _self.latestActivityTime : latestActivityTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreActiveFollower].
extension CoreActiveFollowerPatterns on CoreActiveFollower {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreActiveFollower value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreActiveFollower() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreActiveFollower value)  $default,){
final _that = this;
switch (_that) {
case _CoreActiveFollower():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreActiveFollower value)?  $default,){
final _that = this;
switch (_that) {
case _CoreActiveFollower() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int uid,  String username,  String avatarUrl,  String latestActivityTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreActiveFollower() when $default != null:
return $default(_that.uid,_that.username,_that.avatarUrl,_that.latestActivityTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int uid,  String username,  String avatarUrl,  String latestActivityTime)  $default,) {final _that = this;
switch (_that) {
case _CoreActiveFollower():
return $default(_that.uid,_that.username,_that.avatarUrl,_that.latestActivityTime);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int uid,  String username,  String avatarUrl,  String latestActivityTime)?  $default,) {final _that = this;
switch (_that) {
case _CoreActiveFollower() when $default != null:
return $default(_that.uid,_that.username,_that.avatarUrl,_that.latestActivityTime);case _:
  return null;

}
}

}

/// @nodoc


class _CoreActiveFollower implements CoreActiveFollower {
  const _CoreActiveFollower({required this.uid, required this.username, required this.avatarUrl, required this.latestActivityTime});
  

@override final  int uid;
@override final  String username;
@override final  String avatarUrl;
@override final  String latestActivityTime;

/// Create a copy of CoreActiveFollower
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreActiveFollowerCopyWith<_CoreActiveFollower> get copyWith => __$CoreActiveFollowerCopyWithImpl<_CoreActiveFollower>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreActiveFollower&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.latestActivityTime, latestActivityTime) || other.latestActivityTime == latestActivityTime));
}


@override
int get hashCode => Object.hash(runtimeType,uid,username,avatarUrl,latestActivityTime);

@override
String toString() {
  return 'CoreActiveFollower(uid: $uid, username: $username, avatarUrl: $avatarUrl, latestActivityTime: $latestActivityTime)';
}


}

/// @nodoc
abstract mixin class _$CoreActiveFollowerCopyWith<$Res> implements $CoreActiveFollowerCopyWith<$Res> {
  factory _$CoreActiveFollowerCopyWith(_CoreActiveFollower value, $Res Function(_CoreActiveFollower) _then) = __$CoreActiveFollowerCopyWithImpl;
@override @useResult
$Res call({
 int uid, String username, String avatarUrl, String latestActivityTime
});




}
/// @nodoc
class __$CoreActiveFollowerCopyWithImpl<$Res>
    implements _$CoreActiveFollowerCopyWith<$Res> {
  __$CoreActiveFollowerCopyWithImpl(this._self, this._then);

  final _CoreActiveFollower _self;
  final $Res Function(_CoreActiveFollower) _then;

/// Create a copy of CoreActiveFollower
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? username = null,Object? avatarUrl = null,Object? latestActivityTime = null,}) {
  return _then(_CoreActiveFollower(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,latestActivityTime: null == latestActivityTime ? _self.latestActivityTime : latestActivityTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
