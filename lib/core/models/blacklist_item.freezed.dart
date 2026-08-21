// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blacklist_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoreBlackListItem {

 int? get mid; int? get mtime; String? get uname; String? get face;
/// Create a copy of CoreBlackListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreBlackListItemCopyWith<CoreBlackListItem> get copyWith => _$CoreBlackListItemCopyWithImpl<CoreBlackListItem>(this as CoreBlackListItem, _$identity);

  /// Serializes this CoreBlackListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreBlackListItem&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.mtime, mtime) || other.mtime == mtime)&&(identical(other.uname, uname) || other.uname == uname)&&(identical(other.face, face) || other.face == face));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mid,mtime,uname,face);

@override
String toString() {
  return 'CoreBlackListItem(mid: $mid, mtime: $mtime, uname: $uname, face: $face)';
}


}

/// @nodoc
abstract mixin class $CoreBlackListItemCopyWith<$Res>  {
  factory $CoreBlackListItemCopyWith(CoreBlackListItem value, $Res Function(CoreBlackListItem) _then) = _$CoreBlackListItemCopyWithImpl;
@useResult
$Res call({
 int? mid, int? mtime, String? uname, String? face
});




}
/// @nodoc
class _$CoreBlackListItemCopyWithImpl<$Res>
    implements $CoreBlackListItemCopyWith<$Res> {
  _$CoreBlackListItemCopyWithImpl(this._self, this._then);

  final CoreBlackListItem _self;
  final $Res Function(CoreBlackListItem) _then;

/// Create a copy of CoreBlackListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = freezed,Object? mtime = freezed,Object? uname = freezed,Object? face = freezed,}) {
  return _then(_self.copyWith(
mid: freezed == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int?,mtime: freezed == mtime ? _self.mtime : mtime // ignore: cast_nullable_to_non_nullable
as int?,uname: freezed == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String?,face: freezed == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreBlackListItem].
extension CoreBlackListItemPatterns on CoreBlackListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreBlackListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreBlackListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreBlackListItem value)  $default,){
final _that = this;
switch (_that) {
case _CoreBlackListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreBlackListItem value)?  $default,){
final _that = this;
switch (_that) {
case _CoreBlackListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? mid,  int? mtime,  String? uname,  String? face)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreBlackListItem() when $default != null:
return $default(_that.mid,_that.mtime,_that.uname,_that.face);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? mid,  int? mtime,  String? uname,  String? face)  $default,) {final _that = this;
switch (_that) {
case _CoreBlackListItem():
return $default(_that.mid,_that.mtime,_that.uname,_that.face);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? mid,  int? mtime,  String? uname,  String? face)?  $default,) {final _that = this;
switch (_that) {
case _CoreBlackListItem() when $default != null:
return $default(_that.mid,_that.mtime,_that.uname,_that.face);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreBlackListItem implements CoreBlackListItem {
  const _CoreBlackListItem({this.mid, this.mtime, this.uname, this.face});
  factory _CoreBlackListItem.fromJson(Map<String, dynamic> json) => _$CoreBlackListItemFromJson(json);

@override final  int? mid;
@override final  int? mtime;
@override final  String? uname;
@override final  String? face;

/// Create a copy of CoreBlackListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreBlackListItemCopyWith<_CoreBlackListItem> get copyWith => __$CoreBlackListItemCopyWithImpl<_CoreBlackListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreBlackListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreBlackListItem&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.mtime, mtime) || other.mtime == mtime)&&(identical(other.uname, uname) || other.uname == uname)&&(identical(other.face, face) || other.face == face));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mid,mtime,uname,face);

@override
String toString() {
  return 'CoreBlackListItem(mid: $mid, mtime: $mtime, uname: $uname, face: $face)';
}


}

/// @nodoc
abstract mixin class _$CoreBlackListItemCopyWith<$Res> implements $CoreBlackListItemCopyWith<$Res> {
  factory _$CoreBlackListItemCopyWith(_CoreBlackListItem value, $Res Function(_CoreBlackListItem) _then) = __$CoreBlackListItemCopyWithImpl;
@override @useResult
$Res call({
 int? mid, int? mtime, String? uname, String? face
});




}
/// @nodoc
class __$CoreBlackListItemCopyWithImpl<$Res>
    implements _$CoreBlackListItemCopyWith<$Res> {
  __$CoreBlackListItemCopyWithImpl(this._self, this._then);

  final _CoreBlackListItem _self;
  final $Res Function(_CoreBlackListItem) _then;

/// Create a copy of CoreBlackListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = freezed,Object? mtime = freezed,Object? uname = freezed,Object? face = freezed,}) {
  return _then(_CoreBlackListItem(
mid: freezed == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int?,mtime: freezed == mtime ? _self.mtime : mtime // ignore: cast_nullable_to_non_nullable
as int?,uname: freezed == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String?,face: freezed == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
