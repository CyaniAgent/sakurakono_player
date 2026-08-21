// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreFollowStatus {

 int get status;
/// Create a copy of CoreFollowStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreFollowStatusCopyWith<CoreFollowStatus> get copyWith => _$CoreFollowStatusCopyWithImpl<CoreFollowStatus>(this as CoreFollowStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreFollowStatus&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'CoreFollowStatus(status: $status)';
}


}

/// @nodoc
abstract mixin class $CoreFollowStatusCopyWith<$Res>  {
  factory $CoreFollowStatusCopyWith(CoreFollowStatus value, $Res Function(CoreFollowStatus) _then) = _$CoreFollowStatusCopyWithImpl;
@useResult
$Res call({
 int status
});




}
/// @nodoc
class _$CoreFollowStatusCopyWithImpl<$Res>
    implements $CoreFollowStatusCopyWith<$Res> {
  _$CoreFollowStatusCopyWithImpl(this._self, this._then);

  final CoreFollowStatus _self;
  final $Res Function(CoreFollowStatus) _then;

/// Create a copy of CoreFollowStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreFollowStatus].
extension CoreFollowStatusPatterns on CoreFollowStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreFollowStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreFollowStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreFollowStatus value)  $default,){
final _that = this;
switch (_that) {
case _CoreFollowStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreFollowStatus value)?  $default,){
final _that = this;
switch (_that) {
case _CoreFollowStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreFollowStatus() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int status)  $default,) {final _that = this;
switch (_that) {
case _CoreFollowStatus():
return $default(_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int status)?  $default,) {final _that = this;
switch (_that) {
case _CoreFollowStatus() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _CoreFollowStatus implements CoreFollowStatus {
  const _CoreFollowStatus({required this.status});
  

@override final  int status;

/// Create a copy of CoreFollowStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreFollowStatusCopyWith<_CoreFollowStatus> get copyWith => __$CoreFollowStatusCopyWithImpl<_CoreFollowStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreFollowStatus&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'CoreFollowStatus(status: $status)';
}


}

/// @nodoc
abstract mixin class _$CoreFollowStatusCopyWith<$Res> implements $CoreFollowStatusCopyWith<$Res> {
  factory _$CoreFollowStatusCopyWith(_CoreFollowStatus value, $Res Function(_CoreFollowStatus) _then) = __$CoreFollowStatusCopyWithImpl;
@override @useResult
$Res call({
 int status
});




}
/// @nodoc
class __$CoreFollowStatusCopyWithImpl<$Res>
    implements _$CoreFollowStatusCopyWith<$Res> {
  __$CoreFollowStatusCopyWithImpl(this._self, this._then);

  final _CoreFollowStatus _self;
  final $Res Function(_CoreFollowStatus) _then;

/// Create a copy of CoreFollowStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_CoreFollowStatus(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
