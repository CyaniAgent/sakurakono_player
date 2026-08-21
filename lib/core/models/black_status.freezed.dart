// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'black_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreBlackStatus {

/// Target user UID.
 int get targetUserId;/// Whether the current user has blocked the target.
 bool get iBlocked;/// Whether the target has blocked the current user.
 bool get heBlocked;/// Whether the blocking is mutual (both sides).
 bool get mutualBlock;/// Whether any blocking relationship exists.
 bool get anyBlock;
/// Create a copy of CoreBlackStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreBlackStatusCopyWith<CoreBlackStatus> get copyWith => _$CoreBlackStatusCopyWithImpl<CoreBlackStatus>(this as CoreBlackStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreBlackStatus&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.iBlocked, iBlocked) || other.iBlocked == iBlocked)&&(identical(other.heBlocked, heBlocked) || other.heBlocked == heBlocked)&&(identical(other.mutualBlock, mutualBlock) || other.mutualBlock == mutualBlock)&&(identical(other.anyBlock, anyBlock) || other.anyBlock == anyBlock));
}


@override
int get hashCode => Object.hash(runtimeType,targetUserId,iBlocked,heBlocked,mutualBlock,anyBlock);

@override
String toString() {
  return 'CoreBlackStatus(targetUserId: $targetUserId, iBlocked: $iBlocked, heBlocked: $heBlocked, mutualBlock: $mutualBlock, anyBlock: $anyBlock)';
}


}

/// @nodoc
abstract mixin class $CoreBlackStatusCopyWith<$Res>  {
  factory $CoreBlackStatusCopyWith(CoreBlackStatus value, $Res Function(CoreBlackStatus) _then) = _$CoreBlackStatusCopyWithImpl;
@useResult
$Res call({
 int targetUserId, bool iBlocked, bool heBlocked, bool mutualBlock, bool anyBlock
});




}
/// @nodoc
class _$CoreBlackStatusCopyWithImpl<$Res>
    implements $CoreBlackStatusCopyWith<$Res> {
  _$CoreBlackStatusCopyWithImpl(this._self, this._then);

  final CoreBlackStatus _self;
  final $Res Function(CoreBlackStatus) _then;

/// Create a copy of CoreBlackStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetUserId = null,Object? iBlocked = null,Object? heBlocked = null,Object? mutualBlock = null,Object? anyBlock = null,}) {
  return _then(_self.copyWith(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as int,iBlocked: null == iBlocked ? _self.iBlocked : iBlocked // ignore: cast_nullable_to_non_nullable
as bool,heBlocked: null == heBlocked ? _self.heBlocked : heBlocked // ignore: cast_nullable_to_non_nullable
as bool,mutualBlock: null == mutualBlock ? _self.mutualBlock : mutualBlock // ignore: cast_nullable_to_non_nullable
as bool,anyBlock: null == anyBlock ? _self.anyBlock : anyBlock // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreBlackStatus].
extension CoreBlackStatusPatterns on CoreBlackStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreBlackStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreBlackStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreBlackStatus value)  $default,){
final _that = this;
switch (_that) {
case _CoreBlackStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreBlackStatus value)?  $default,){
final _that = this;
switch (_that) {
case _CoreBlackStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int targetUserId,  bool iBlocked,  bool heBlocked,  bool mutualBlock,  bool anyBlock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreBlackStatus() when $default != null:
return $default(_that.targetUserId,_that.iBlocked,_that.heBlocked,_that.mutualBlock,_that.anyBlock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int targetUserId,  bool iBlocked,  bool heBlocked,  bool mutualBlock,  bool anyBlock)  $default,) {final _that = this;
switch (_that) {
case _CoreBlackStatus():
return $default(_that.targetUserId,_that.iBlocked,_that.heBlocked,_that.mutualBlock,_that.anyBlock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int targetUserId,  bool iBlocked,  bool heBlocked,  bool mutualBlock,  bool anyBlock)?  $default,) {final _that = this;
switch (_that) {
case _CoreBlackStatus() when $default != null:
return $default(_that.targetUserId,_that.iBlocked,_that.heBlocked,_that.mutualBlock,_that.anyBlock);case _:
  return null;

}
}

}

/// @nodoc


class _CoreBlackStatus implements CoreBlackStatus {
  const _CoreBlackStatus({required this.targetUserId, required this.iBlocked, required this.heBlocked, required this.mutualBlock, required this.anyBlock});
  

/// Target user UID.
@override final  int targetUserId;
/// Whether the current user has blocked the target.
@override final  bool iBlocked;
/// Whether the target has blocked the current user.
@override final  bool heBlocked;
/// Whether the blocking is mutual (both sides).
@override final  bool mutualBlock;
/// Whether any blocking relationship exists.
@override final  bool anyBlock;

/// Create a copy of CoreBlackStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreBlackStatusCopyWith<_CoreBlackStatus> get copyWith => __$CoreBlackStatusCopyWithImpl<_CoreBlackStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreBlackStatus&&(identical(other.targetUserId, targetUserId) || other.targetUserId == targetUserId)&&(identical(other.iBlocked, iBlocked) || other.iBlocked == iBlocked)&&(identical(other.heBlocked, heBlocked) || other.heBlocked == heBlocked)&&(identical(other.mutualBlock, mutualBlock) || other.mutualBlock == mutualBlock)&&(identical(other.anyBlock, anyBlock) || other.anyBlock == anyBlock));
}


@override
int get hashCode => Object.hash(runtimeType,targetUserId,iBlocked,heBlocked,mutualBlock,anyBlock);

@override
String toString() {
  return 'CoreBlackStatus(targetUserId: $targetUserId, iBlocked: $iBlocked, heBlocked: $heBlocked, mutualBlock: $mutualBlock, anyBlock: $anyBlock)';
}


}

/// @nodoc
abstract mixin class _$CoreBlackStatusCopyWith<$Res> implements $CoreBlackStatusCopyWith<$Res> {
  factory _$CoreBlackStatusCopyWith(_CoreBlackStatus value, $Res Function(_CoreBlackStatus) _then) = __$CoreBlackStatusCopyWithImpl;
@override @useResult
$Res call({
 int targetUserId, bool iBlocked, bool heBlocked, bool mutualBlock, bool anyBlock
});




}
/// @nodoc
class __$CoreBlackStatusCopyWithImpl<$Res>
    implements _$CoreBlackStatusCopyWith<$Res> {
  __$CoreBlackStatusCopyWithImpl(this._self, this._then);

  final _CoreBlackStatus _self;
  final $Res Function(_CoreBlackStatus) _then;

/// Create a copy of CoreBlackStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetUserId = null,Object? iBlocked = null,Object? heBlocked = null,Object? mutualBlock = null,Object? anyBlock = null,}) {
  return _then(_CoreBlackStatus(
targetUserId: null == targetUserId ? _self.targetUserId : targetUserId // ignore: cast_nullable_to_non_nullable
as int,iBlocked: null == iBlocked ? _self.iBlocked : iBlocked // ignore: cast_nullable_to_non_nullable
as bool,heBlocked: null == heBlocked ? _self.heBlocked : heBlocked // ignore: cast_nullable_to_non_nullable
as bool,mutualBlock: null == mutualBlock ? _self.mutualBlock : mutualBlock // ignore: cast_nullable_to_non_nullable
as bool,anyBlock: null == anyBlock ? _self.anyBlock : anyBlock // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
