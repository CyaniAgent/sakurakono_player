// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blacklist_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreBlackListData {

 List<CoreBlackListItem>? get list; int? get total;
/// Create a copy of CoreBlackListData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreBlackListDataCopyWith<CoreBlackListData> get copyWith => _$CoreBlackListDataCopyWithImpl<CoreBlackListData>(this as CoreBlackListData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreBlackListData&&const DeepCollectionEquality().equals(other.list, list)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(list),total);

@override
String toString() {
  return 'CoreBlackListData(list: $list, total: $total)';
}


}

/// @nodoc
abstract mixin class $CoreBlackListDataCopyWith<$Res>  {
  factory $CoreBlackListDataCopyWith(CoreBlackListData value, $Res Function(CoreBlackListData) _then) = _$CoreBlackListDataCopyWithImpl;
@useResult
$Res call({
 List<CoreBlackListItem>? list, int? total
});




}
/// @nodoc
class _$CoreBlackListDataCopyWithImpl<$Res>
    implements $CoreBlackListDataCopyWith<$Res> {
  _$CoreBlackListDataCopyWithImpl(this._self, this._then);

  final CoreBlackListData _self;
  final $Res Function(CoreBlackListData) _then;

/// Create a copy of CoreBlackListData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? list = freezed,Object? total = freezed,}) {
  return _then(_self.copyWith(
list: freezed == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as List<CoreBlackListItem>?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreBlackListData].
extension CoreBlackListDataPatterns on CoreBlackListData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreBlackListData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreBlackListData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreBlackListData value)  $default,){
final _that = this;
switch (_that) {
case _CoreBlackListData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreBlackListData value)?  $default,){
final _that = this;
switch (_that) {
case _CoreBlackListData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CoreBlackListItem>? list,  int? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreBlackListData() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CoreBlackListItem>? list,  int? total)  $default,) {final _that = this;
switch (_that) {
case _CoreBlackListData():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CoreBlackListItem>? list,  int? total)?  $default,) {final _that = this;
switch (_that) {
case _CoreBlackListData() when $default != null:
return $default(_that.list,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _CoreBlackListData implements CoreBlackListData {
  const _CoreBlackListData({final  List<CoreBlackListItem>? list, this.total}): _list = list;
  

 final  List<CoreBlackListItem>? _list;
@override List<CoreBlackListItem>? get list {
  final value = _list;
  if (value == null) return null;
  if (_list is EqualUnmodifiableListView) return _list;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? total;

/// Create a copy of CoreBlackListData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreBlackListDataCopyWith<_CoreBlackListData> get copyWith => __$CoreBlackListDataCopyWithImpl<_CoreBlackListData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreBlackListData&&const DeepCollectionEquality().equals(other._list, _list)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_list),total);

@override
String toString() {
  return 'CoreBlackListData(list: $list, total: $total)';
}


}

/// @nodoc
abstract mixin class _$CoreBlackListDataCopyWith<$Res> implements $CoreBlackListDataCopyWith<$Res> {
  factory _$CoreBlackListDataCopyWith(_CoreBlackListData value, $Res Function(_CoreBlackListData) _then) = __$CoreBlackListDataCopyWithImpl;
@override @useResult
$Res call({
 List<CoreBlackListItem>? list, int? total
});




}
/// @nodoc
class __$CoreBlackListDataCopyWithImpl<$Res>
    implements _$CoreBlackListDataCopyWith<$Res> {
  __$CoreBlackListDataCopyWithImpl(this._self, this._then);

  final _CoreBlackListData _self;
  final $Res Function(_CoreBlackListData) _then;

/// Create a copy of CoreBlackListData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? list = freezed,Object? total = freezed,}) {
  return _then(_CoreBlackListData(
list: freezed == list ? _self._list : list // ignore: cast_nullable_to_non_nullable
as List<CoreBlackListItem>?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
