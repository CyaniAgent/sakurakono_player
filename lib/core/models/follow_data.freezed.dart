// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreFollowData {

 List<CoreFollowItemModel>? get list; int? get total;
/// Create a copy of CoreFollowData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreFollowDataCopyWith<CoreFollowData> get copyWith => _$CoreFollowDataCopyWithImpl<CoreFollowData>(this as CoreFollowData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreFollowData&&const DeepCollectionEquality().equals(other.list, list)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(list),total);

@override
String toString() {
  return 'CoreFollowData(list: $list, total: $total)';
}


}

/// @nodoc
abstract mixin class $CoreFollowDataCopyWith<$Res>  {
  factory $CoreFollowDataCopyWith(CoreFollowData value, $Res Function(CoreFollowData) _then) = _$CoreFollowDataCopyWithImpl;
@useResult
$Res call({
 List<CoreFollowItemModel>? list, int? total
});




}
/// @nodoc
class _$CoreFollowDataCopyWithImpl<$Res>
    implements $CoreFollowDataCopyWith<$Res> {
  _$CoreFollowDataCopyWithImpl(this._self, this._then);

  final CoreFollowData _self;
  final $Res Function(CoreFollowData) _then;

/// Create a copy of CoreFollowData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? list = freezed,Object? total = freezed,}) {
  return _then(_self.copyWith(
list: freezed == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as List<CoreFollowItemModel>?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreFollowData].
extension CoreFollowDataPatterns on CoreFollowData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreFollowData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreFollowData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreFollowData value)  $default,){
final _that = this;
switch (_that) {
case _CoreFollowData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreFollowData value)?  $default,){
final _that = this;
switch (_that) {
case _CoreFollowData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CoreFollowItemModel>? list,  int? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreFollowData() when $default != null:
return $default(_that.list,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CoreFollowItemModel>? list,  int? total)  $default,) {final _that = this;
switch (_that) {
case _CoreFollowData():
return $default(_that.list,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CoreFollowItemModel>? list,  int? total)?  $default,) {final _that = this;
switch (_that) {
case _CoreFollowData() when $default != null:
return $default(_that.list,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _CoreFollowData implements CoreFollowData {
  const _CoreFollowData({final  List<CoreFollowItemModel>? list, this.total}): _list = list;
  

 final  List<CoreFollowItemModel>? _list;
@override List<CoreFollowItemModel>? get list {
  final value = _list;
  if (value == null) return null;
  if (_list is EqualUnmodifiableListView) return _list;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? total;

/// Create a copy of CoreFollowData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreFollowDataCopyWith<_CoreFollowData> get copyWith => __$CoreFollowDataCopyWithImpl<_CoreFollowData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreFollowData&&const DeepCollectionEquality().equals(other._list, _list)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_list),total);

@override
String toString() {
  return 'CoreFollowData(list: $list, total: $total)';
}


}

/// @nodoc
abstract mixin class _$CoreFollowDataCopyWith<$Res> implements $CoreFollowDataCopyWith<$Res> {
  factory _$CoreFollowDataCopyWith(_CoreFollowData value, $Res Function(_CoreFollowData) _then) = __$CoreFollowDataCopyWithImpl;
@override @useResult
$Res call({
 List<CoreFollowItemModel>? list, int? total
});




}
/// @nodoc
class __$CoreFollowDataCopyWithImpl<$Res>
    implements _$CoreFollowDataCopyWith<$Res> {
  __$CoreFollowDataCopyWithImpl(this._self, this._then);

  final _CoreFollowData _self;
  final $Res Function(_CoreFollowData) _then;

/// Create a copy of CoreFollowData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? list = freezed,Object? total = freezed,}) {
  return _then(_CoreFollowData(
list: freezed == list ? _self._list : list // ignore: cast_nullable_to_non_nullable
as List<CoreFollowItemModel>?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
