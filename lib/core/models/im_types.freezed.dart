// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'im_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreImOffset {

 int get normalOffset; int get topOffset;
/// Create a copy of CoreImOffset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImOffsetCopyWith<CoreImOffset> get copyWith => _$CoreImOffsetCopyWithImpl<CoreImOffset>(this as CoreImOffset, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImOffset&&(identical(other.normalOffset, normalOffset) || other.normalOffset == normalOffset)&&(identical(other.topOffset, topOffset) || other.topOffset == topOffset));
}


@override
int get hashCode => Object.hash(runtimeType,normalOffset,topOffset);

@override
String toString() {
  return 'CoreImOffset(normalOffset: $normalOffset, topOffset: $topOffset)';
}


}

/// @nodoc
abstract mixin class $CoreImOffsetCopyWith<$Res>  {
  factory $CoreImOffsetCopyWith(CoreImOffset value, $Res Function(CoreImOffset) _then) = _$CoreImOffsetCopyWithImpl;
@useResult
$Res call({
 int normalOffset, int topOffset
});




}
/// @nodoc
class _$CoreImOffsetCopyWithImpl<$Res>
    implements $CoreImOffsetCopyWith<$Res> {
  _$CoreImOffsetCopyWithImpl(this._self, this._then);

  final CoreImOffset _self;
  final $Res Function(CoreImOffset) _then;

/// Create a copy of CoreImOffset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? normalOffset = null,Object? topOffset = null,}) {
  return _then(_self.copyWith(
normalOffset: null == normalOffset ? _self.normalOffset : normalOffset // ignore: cast_nullable_to_non_nullable
as int,topOffset: null == topOffset ? _self.topOffset : topOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImOffset].
extension CoreImOffsetPatterns on CoreImOffset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImOffset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImOffset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImOffset value)  $default,){
final _that = this;
switch (_that) {
case _CoreImOffset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImOffset value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImOffset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int normalOffset,  int topOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImOffset() when $default != null:
return $default(_that.normalOffset,_that.topOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int normalOffset,  int topOffset)  $default,) {final _that = this;
switch (_that) {
case _CoreImOffset():
return $default(_that.normalOffset,_that.topOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int normalOffset,  int topOffset)?  $default,) {final _that = this;
switch (_that) {
case _CoreImOffset() when $default != null:
return $default(_that.normalOffset,_that.topOffset);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImOffset implements CoreImOffset {
  const _CoreImOffset({this.normalOffset = 0, this.topOffset = 0});
  

@override@JsonKey() final  int normalOffset;
@override@JsonKey() final  int topOffset;

/// Create a copy of CoreImOffset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImOffsetCopyWith<_CoreImOffset> get copyWith => __$CoreImOffsetCopyWithImpl<_CoreImOffset>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImOffset&&(identical(other.normalOffset, normalOffset) || other.normalOffset == normalOffset)&&(identical(other.topOffset, topOffset) || other.topOffset == topOffset));
}


@override
int get hashCode => Object.hash(runtimeType,normalOffset,topOffset);

@override
String toString() {
  return 'CoreImOffset(normalOffset: $normalOffset, topOffset: $topOffset)';
}


}

/// @nodoc
abstract mixin class _$CoreImOffsetCopyWith<$Res> implements $CoreImOffsetCopyWith<$Res> {
  factory _$CoreImOffsetCopyWith(_CoreImOffset value, $Res Function(_CoreImOffset) _then) = __$CoreImOffsetCopyWithImpl;
@override @useResult
$Res call({
 int normalOffset, int topOffset
});




}
/// @nodoc
class __$CoreImOffsetCopyWithImpl<$Res>
    implements _$CoreImOffsetCopyWith<$Res> {
  __$CoreImOffsetCopyWithImpl(this._self, this._then);

  final _CoreImOffset _self;
  final $Res Function(_CoreImOffset) _then;

/// Create a copy of CoreImOffset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? normalOffset = null,Object? topOffset = null,}) {
  return _then(_CoreImOffset(
normalOffset: null == normalOffset ? _self.normalOffset : normalOffset // ignore: cast_nullable_to_non_nullable
as int,topOffset: null == topOffset ? _self.topOffset : topOffset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CoreImSessionId {

 int? get privateTalkerUid; int? get groupId;
/// Create a copy of CoreImSessionId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImSessionIdCopyWith<CoreImSessionId> get copyWith => _$CoreImSessionIdCopyWithImpl<CoreImSessionId>(this as CoreImSessionId, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImSessionId&&(identical(other.privateTalkerUid, privateTalkerUid) || other.privateTalkerUid == privateTalkerUid)&&(identical(other.groupId, groupId) || other.groupId == groupId));
}


@override
int get hashCode => Object.hash(runtimeType,privateTalkerUid,groupId);

@override
String toString() {
  return 'CoreImSessionId(privateTalkerUid: $privateTalkerUid, groupId: $groupId)';
}


}

/// @nodoc
abstract mixin class $CoreImSessionIdCopyWith<$Res>  {
  factory $CoreImSessionIdCopyWith(CoreImSessionId value, $Res Function(CoreImSessionId) _then) = _$CoreImSessionIdCopyWithImpl;
@useResult
$Res call({
 int? privateTalkerUid, int? groupId
});




}
/// @nodoc
class _$CoreImSessionIdCopyWithImpl<$Res>
    implements $CoreImSessionIdCopyWith<$Res> {
  _$CoreImSessionIdCopyWithImpl(this._self, this._then);

  final CoreImSessionId _self;
  final $Res Function(CoreImSessionId) _then;

/// Create a copy of CoreImSessionId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? privateTalkerUid = freezed,Object? groupId = freezed,}) {
  return _then(_self.copyWith(
privateTalkerUid: freezed == privateTalkerUid ? _self.privateTalkerUid : privateTalkerUid // ignore: cast_nullable_to_non_nullable
as int?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImSessionId].
extension CoreImSessionIdPatterns on CoreImSessionId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImSessionId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImSessionId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImSessionId value)  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImSessionId value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? privateTalkerUid,  int? groupId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImSessionId() when $default != null:
return $default(_that.privateTalkerUid,_that.groupId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? privateTalkerUid,  int? groupId)  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionId():
return $default(_that.privateTalkerUid,_that.groupId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? privateTalkerUid,  int? groupId)?  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionId() when $default != null:
return $default(_that.privateTalkerUid,_that.groupId);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImSessionId implements CoreImSessionId {
  const _CoreImSessionId({this.privateTalkerUid, this.groupId});
  

@override final  int? privateTalkerUid;
@override final  int? groupId;

/// Create a copy of CoreImSessionId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImSessionIdCopyWith<_CoreImSessionId> get copyWith => __$CoreImSessionIdCopyWithImpl<_CoreImSessionId>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImSessionId&&(identical(other.privateTalkerUid, privateTalkerUid) || other.privateTalkerUid == privateTalkerUid)&&(identical(other.groupId, groupId) || other.groupId == groupId));
}


@override
int get hashCode => Object.hash(runtimeType,privateTalkerUid,groupId);

@override
String toString() {
  return 'CoreImSessionId(privateTalkerUid: $privateTalkerUid, groupId: $groupId)';
}


}

/// @nodoc
abstract mixin class _$CoreImSessionIdCopyWith<$Res> implements $CoreImSessionIdCopyWith<$Res> {
  factory _$CoreImSessionIdCopyWith(_CoreImSessionId value, $Res Function(_CoreImSessionId) _then) = __$CoreImSessionIdCopyWithImpl;
@override @useResult
$Res call({
 int? privateTalkerUid, int? groupId
});




}
/// @nodoc
class __$CoreImSessionIdCopyWithImpl<$Res>
    implements _$CoreImSessionIdCopyWith<$Res> {
  __$CoreImSessionIdCopyWithImpl(this._self, this._then);

  final _CoreImSessionId _self;
  final $Res Function(_CoreImSessionId) _then;

/// Create a copy of CoreImSessionId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? privateTalkerUid = freezed,Object? groupId = freezed,}) {
  return _then(_CoreImSessionId(
privateTalkerUid: freezed == privateTalkerUid ? _self.privateTalkerUid : privateTalkerUid // ignore: cast_nullable_to_non_nullable
as int?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$CoreImSetting {

 bool? get switchValue; String? get textValue;
/// Create a copy of CoreImSetting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImSettingCopyWith<CoreImSetting> get copyWith => _$CoreImSettingCopyWithImpl<CoreImSetting>(this as CoreImSetting, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImSetting&&(identical(other.switchValue, switchValue) || other.switchValue == switchValue)&&(identical(other.textValue, textValue) || other.textValue == textValue));
}


@override
int get hashCode => Object.hash(runtimeType,switchValue,textValue);

@override
String toString() {
  return 'CoreImSetting(switchValue: $switchValue, textValue: $textValue)';
}


}

/// @nodoc
abstract mixin class $CoreImSettingCopyWith<$Res>  {
  factory $CoreImSettingCopyWith(CoreImSetting value, $Res Function(CoreImSetting) _then) = _$CoreImSettingCopyWithImpl;
@useResult
$Res call({
 bool? switchValue, String? textValue
});




}
/// @nodoc
class _$CoreImSettingCopyWithImpl<$Res>
    implements $CoreImSettingCopyWith<$Res> {
  _$CoreImSettingCopyWithImpl(this._self, this._then);

  final CoreImSetting _self;
  final $Res Function(CoreImSetting) _then;

/// Create a copy of CoreImSetting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? switchValue = freezed,Object? textValue = freezed,}) {
  return _then(_self.copyWith(
switchValue: freezed == switchValue ? _self.switchValue : switchValue // ignore: cast_nullable_to_non_nullable
as bool?,textValue: freezed == textValue ? _self.textValue : textValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImSetting].
extension CoreImSettingPatterns on CoreImSetting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImSetting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImSetting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImSetting value)  $default,){
final _that = this;
switch (_that) {
case _CoreImSetting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImSetting value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImSetting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? switchValue,  String? textValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImSetting() when $default != null:
return $default(_that.switchValue,_that.textValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? switchValue,  String? textValue)  $default,) {final _that = this;
switch (_that) {
case _CoreImSetting():
return $default(_that.switchValue,_that.textValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? switchValue,  String? textValue)?  $default,) {final _that = this;
switch (_that) {
case _CoreImSetting() when $default != null:
return $default(_that.switchValue,_that.textValue);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImSetting implements CoreImSetting {
  const _CoreImSetting({this.switchValue, this.textValue});
  

@override final  bool? switchValue;
@override final  String? textValue;

/// Create a copy of CoreImSetting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImSettingCopyWith<_CoreImSetting> get copyWith => __$CoreImSettingCopyWithImpl<_CoreImSetting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImSetting&&(identical(other.switchValue, switchValue) || other.switchValue == switchValue)&&(identical(other.textValue, textValue) || other.textValue == textValue));
}


@override
int get hashCode => Object.hash(runtimeType,switchValue,textValue);

@override
String toString() {
  return 'CoreImSetting(switchValue: $switchValue, textValue: $textValue)';
}


}

/// @nodoc
abstract mixin class _$CoreImSettingCopyWith<$Res> implements $CoreImSettingCopyWith<$Res> {
  factory _$CoreImSettingCopyWith(_CoreImSetting value, $Res Function(_CoreImSetting) _then) = __$CoreImSettingCopyWithImpl;
@override @useResult
$Res call({
 bool? switchValue, String? textValue
});




}
/// @nodoc
class __$CoreImSettingCopyWithImpl<$Res>
    implements _$CoreImSettingCopyWith<$Res> {
  __$CoreImSettingCopyWithImpl(this._self, this._then);

  final _CoreImSetting _self;
  final $Res Function(_CoreImSetting) _then;

/// Create a copy of CoreImSetting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? switchValue = freezed,Object? textValue = freezed,}) {
  return _then(_CoreImSetting(
switchValue: freezed == switchValue ? _self.switchValue : switchValue // ignore: cast_nullable_to_non_nullable
as bool?,textValue: freezed == textValue ? _self.textValue : textValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CoreImShareSessionInfo {

 int get talkerId; String get talkerUname; String get talkerIcon;
/// Create a copy of CoreImShareSessionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImShareSessionInfoCopyWith<CoreImShareSessionInfo> get copyWith => _$CoreImShareSessionInfoCopyWithImpl<CoreImShareSessionInfo>(this as CoreImShareSessionInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImShareSessionInfo&&(identical(other.talkerId, talkerId) || other.talkerId == talkerId)&&(identical(other.talkerUname, talkerUname) || other.talkerUname == talkerUname)&&(identical(other.talkerIcon, talkerIcon) || other.talkerIcon == talkerIcon));
}


@override
int get hashCode => Object.hash(runtimeType,talkerId,talkerUname,talkerIcon);

@override
String toString() {
  return 'CoreImShareSessionInfo(talkerId: $talkerId, talkerUname: $talkerUname, talkerIcon: $talkerIcon)';
}


}

/// @nodoc
abstract mixin class $CoreImShareSessionInfoCopyWith<$Res>  {
  factory $CoreImShareSessionInfoCopyWith(CoreImShareSessionInfo value, $Res Function(CoreImShareSessionInfo) _then) = _$CoreImShareSessionInfoCopyWithImpl;
@useResult
$Res call({
 int talkerId, String talkerUname, String talkerIcon
});




}
/// @nodoc
class _$CoreImShareSessionInfoCopyWithImpl<$Res>
    implements $CoreImShareSessionInfoCopyWith<$Res> {
  _$CoreImShareSessionInfoCopyWithImpl(this._self, this._then);

  final CoreImShareSessionInfo _self;
  final $Res Function(CoreImShareSessionInfo) _then;

/// Create a copy of CoreImShareSessionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? talkerId = null,Object? talkerUname = null,Object? talkerIcon = null,}) {
  return _then(_self.copyWith(
talkerId: null == talkerId ? _self.talkerId : talkerId // ignore: cast_nullable_to_non_nullable
as int,talkerUname: null == talkerUname ? _self.talkerUname : talkerUname // ignore: cast_nullable_to_non_nullable
as String,talkerIcon: null == talkerIcon ? _self.talkerIcon : talkerIcon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImShareSessionInfo].
extension CoreImShareSessionInfoPatterns on CoreImShareSessionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImShareSessionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImShareSessionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImShareSessionInfo value)  $default,){
final _that = this;
switch (_that) {
case _CoreImShareSessionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImShareSessionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImShareSessionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int talkerId,  String talkerUname,  String talkerIcon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImShareSessionInfo() when $default != null:
return $default(_that.talkerId,_that.talkerUname,_that.talkerIcon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int talkerId,  String talkerUname,  String talkerIcon)  $default,) {final _that = this;
switch (_that) {
case _CoreImShareSessionInfo():
return $default(_that.talkerId,_that.talkerUname,_that.talkerIcon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int talkerId,  String talkerUname,  String talkerIcon)?  $default,) {final _that = this;
switch (_that) {
case _CoreImShareSessionInfo() when $default != null:
return $default(_that.talkerId,_that.talkerUname,_that.talkerIcon);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImShareSessionInfo implements CoreImShareSessionInfo {
  const _CoreImShareSessionInfo({this.talkerId = 0, this.talkerUname = '', this.talkerIcon = ''});
  

@override@JsonKey() final  int talkerId;
@override@JsonKey() final  String talkerUname;
@override@JsonKey() final  String talkerIcon;

/// Create a copy of CoreImShareSessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImShareSessionInfoCopyWith<_CoreImShareSessionInfo> get copyWith => __$CoreImShareSessionInfoCopyWithImpl<_CoreImShareSessionInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImShareSessionInfo&&(identical(other.talkerId, talkerId) || other.talkerId == talkerId)&&(identical(other.talkerUname, talkerUname) || other.talkerUname == talkerUname)&&(identical(other.talkerIcon, talkerIcon) || other.talkerIcon == talkerIcon));
}


@override
int get hashCode => Object.hash(runtimeType,talkerId,talkerUname,talkerIcon);

@override
String toString() {
  return 'CoreImShareSessionInfo(talkerId: $talkerId, talkerUname: $talkerUname, talkerIcon: $talkerIcon)';
}


}

/// @nodoc
abstract mixin class _$CoreImShareSessionInfoCopyWith<$Res> implements $CoreImShareSessionInfoCopyWith<$Res> {
  factory _$CoreImShareSessionInfoCopyWith(_CoreImShareSessionInfo value, $Res Function(_CoreImShareSessionInfo) _then) = __$CoreImShareSessionInfoCopyWithImpl;
@override @useResult
$Res call({
 int talkerId, String talkerUname, String talkerIcon
});




}
/// @nodoc
class __$CoreImShareSessionInfoCopyWithImpl<$Res>
    implements _$CoreImShareSessionInfoCopyWith<$Res> {
  __$CoreImShareSessionInfoCopyWithImpl(this._self, this._then);

  final _CoreImShareSessionInfo _self;
  final $Res Function(_CoreImShareSessionInfo) _then;

/// Create a copy of CoreImShareSessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? talkerId = null,Object? talkerUname = null,Object? talkerIcon = null,}) {
  return _then(_CoreImShareSessionInfo(
talkerId: null == talkerId ? _self.talkerId : talkerId // ignore: cast_nullable_to_non_nullable
as int,talkerUname: null == talkerUname ? _self.talkerUname : talkerUname // ignore: cast_nullable_to_non_nullable
as String,talkerIcon: null == talkerIcon ? _self.talkerIcon : talkerIcon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CoreImMsg {

 int get msgKey; int get msgType; String get content; int get seqno; int get senderUid; int get timestamp;
/// Create a copy of CoreImMsg
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImMsgCopyWith<CoreImMsg> get copyWith => _$CoreImMsgCopyWithImpl<CoreImMsg>(this as CoreImMsg, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImMsg&&(identical(other.msgKey, msgKey) || other.msgKey == msgKey)&&(identical(other.msgType, msgType) || other.msgType == msgType)&&(identical(other.content, content) || other.content == content)&&(identical(other.seqno, seqno) || other.seqno == seqno)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,msgKey,msgType,content,seqno,senderUid,timestamp);

@override
String toString() {
  return 'CoreImMsg(msgKey: $msgKey, msgType: $msgType, content: $content, seqno: $seqno, senderUid: $senderUid, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $CoreImMsgCopyWith<$Res>  {
  factory $CoreImMsgCopyWith(CoreImMsg value, $Res Function(CoreImMsg) _then) = _$CoreImMsgCopyWithImpl;
@useResult
$Res call({
 int msgKey, int msgType, String content, int seqno, int senderUid, int timestamp
});




}
/// @nodoc
class _$CoreImMsgCopyWithImpl<$Res>
    implements $CoreImMsgCopyWith<$Res> {
  _$CoreImMsgCopyWithImpl(this._self, this._then);

  final CoreImMsg _self;
  final $Res Function(CoreImMsg) _then;

/// Create a copy of CoreImMsg
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? msgKey = null,Object? msgType = null,Object? content = null,Object? seqno = null,Object? senderUid = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
msgKey: null == msgKey ? _self.msgKey : msgKey // ignore: cast_nullable_to_non_nullable
as int,msgType: null == msgType ? _self.msgType : msgType // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,seqno: null == seqno ? _self.seqno : seqno // ignore: cast_nullable_to_non_nullable
as int,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImMsg].
extension CoreImMsgPatterns on CoreImMsg {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImMsg value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImMsg() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImMsg value)  $default,){
final _that = this;
switch (_that) {
case _CoreImMsg():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImMsg value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImMsg() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int msgKey,  int msgType,  String content,  int seqno,  int senderUid,  int timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImMsg() when $default != null:
return $default(_that.msgKey,_that.msgType,_that.content,_that.seqno,_that.senderUid,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int msgKey,  int msgType,  String content,  int seqno,  int senderUid,  int timestamp)  $default,) {final _that = this;
switch (_that) {
case _CoreImMsg():
return $default(_that.msgKey,_that.msgType,_that.content,_that.seqno,_that.senderUid,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int msgKey,  int msgType,  String content,  int seqno,  int senderUid,  int timestamp)?  $default,) {final _that = this;
switch (_that) {
case _CoreImMsg() when $default != null:
return $default(_that.msgKey,_that.msgType,_that.content,_that.seqno,_that.senderUid,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImMsg implements CoreImMsg {
  const _CoreImMsg({this.msgKey = 0, this.msgType = 0, this.content = '', this.seqno = 0, this.senderUid = 0, this.timestamp = 0});
  

@override@JsonKey() final  int msgKey;
@override@JsonKey() final  int msgType;
@override@JsonKey() final  String content;
@override@JsonKey() final  int seqno;
@override@JsonKey() final  int senderUid;
@override@JsonKey() final  int timestamp;

/// Create a copy of CoreImMsg
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImMsgCopyWith<_CoreImMsg> get copyWith => __$CoreImMsgCopyWithImpl<_CoreImMsg>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImMsg&&(identical(other.msgKey, msgKey) || other.msgKey == msgKey)&&(identical(other.msgType, msgType) || other.msgType == msgType)&&(identical(other.content, content) || other.content == content)&&(identical(other.seqno, seqno) || other.seqno == seqno)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,msgKey,msgType,content,seqno,senderUid,timestamp);

@override
String toString() {
  return 'CoreImMsg(msgKey: $msgKey, msgType: $msgType, content: $content, seqno: $seqno, senderUid: $senderUid, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$CoreImMsgCopyWith<$Res> implements $CoreImMsgCopyWith<$Res> {
  factory _$CoreImMsgCopyWith(_CoreImMsg value, $Res Function(_CoreImMsg) _then) = __$CoreImMsgCopyWithImpl;
@override @useResult
$Res call({
 int msgKey, int msgType, String content, int seqno, int senderUid, int timestamp
});




}
/// @nodoc
class __$CoreImMsgCopyWithImpl<$Res>
    implements _$CoreImMsgCopyWith<$Res> {
  __$CoreImMsgCopyWithImpl(this._self, this._then);

  final _CoreImMsg _self;
  final $Res Function(_CoreImMsg) _then;

/// Create a copy of CoreImMsg
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? msgKey = null,Object? msgType = null,Object? content = null,Object? seqno = null,Object? senderUid = null,Object? timestamp = null,}) {
  return _then(_CoreImMsg(
msgKey: null == msgKey ? _self.msgKey : msgKey // ignore: cast_nullable_to_non_nullable
as int,msgType: null == msgType ? _self.msgType : msgType // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,seqno: null == seqno ? _self.seqno : seqno // ignore: cast_nullable_to_non_nullable
as int,senderUid: null == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CoreImSession {

 int get talkerId; int get sessionType; int get unreadCount; int get ackSeqno; String get sessionName; bool get isPinned;
/// Create a copy of CoreImSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImSessionCopyWith<CoreImSession> get copyWith => _$CoreImSessionCopyWithImpl<CoreImSession>(this as CoreImSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImSession&&(identical(other.talkerId, talkerId) || other.talkerId == talkerId)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.ackSeqno, ackSeqno) || other.ackSeqno == ackSeqno)&&(identical(other.sessionName, sessionName) || other.sessionName == sessionName)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned));
}


@override
int get hashCode => Object.hash(runtimeType,talkerId,sessionType,unreadCount,ackSeqno,sessionName,isPinned);

@override
String toString() {
  return 'CoreImSession(talkerId: $talkerId, sessionType: $sessionType, unreadCount: $unreadCount, ackSeqno: $ackSeqno, sessionName: $sessionName, isPinned: $isPinned)';
}


}

/// @nodoc
abstract mixin class $CoreImSessionCopyWith<$Res>  {
  factory $CoreImSessionCopyWith(CoreImSession value, $Res Function(CoreImSession) _then) = _$CoreImSessionCopyWithImpl;
@useResult
$Res call({
 int talkerId, int sessionType, int unreadCount, int ackSeqno, String sessionName, bool isPinned
});




}
/// @nodoc
class _$CoreImSessionCopyWithImpl<$Res>
    implements $CoreImSessionCopyWith<$Res> {
  _$CoreImSessionCopyWithImpl(this._self, this._then);

  final CoreImSession _self;
  final $Res Function(CoreImSession) _then;

/// Create a copy of CoreImSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? talkerId = null,Object? sessionType = null,Object? unreadCount = null,Object? ackSeqno = null,Object? sessionName = null,Object? isPinned = null,}) {
  return _then(_self.copyWith(
talkerId: null == talkerId ? _self.talkerId : talkerId // ignore: cast_nullable_to_non_nullable
as int,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,ackSeqno: null == ackSeqno ? _self.ackSeqno : ackSeqno // ignore: cast_nullable_to_non_nullable
as int,sessionName: null == sessionName ? _self.sessionName : sessionName // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImSession].
extension CoreImSessionPatterns on CoreImSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImSession value)  $default,){
final _that = this;
switch (_that) {
case _CoreImSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImSession value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int talkerId,  int sessionType,  int unreadCount,  int ackSeqno,  String sessionName,  bool isPinned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImSession() when $default != null:
return $default(_that.talkerId,_that.sessionType,_that.unreadCount,_that.ackSeqno,_that.sessionName,_that.isPinned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int talkerId,  int sessionType,  int unreadCount,  int ackSeqno,  String sessionName,  bool isPinned)  $default,) {final _that = this;
switch (_that) {
case _CoreImSession():
return $default(_that.talkerId,_that.sessionType,_that.unreadCount,_that.ackSeqno,_that.sessionName,_that.isPinned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int talkerId,  int sessionType,  int unreadCount,  int ackSeqno,  String sessionName,  bool isPinned)?  $default,) {final _that = this;
switch (_that) {
case _CoreImSession() when $default != null:
return $default(_that.talkerId,_that.sessionType,_that.unreadCount,_that.ackSeqno,_that.sessionName,_that.isPinned);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImSession implements CoreImSession {
  const _CoreImSession({this.talkerId = 0, this.sessionType = 0, this.unreadCount = 0, this.ackSeqno = 0, this.sessionName = '', this.isPinned = false});
  

@override@JsonKey() final  int talkerId;
@override@JsonKey() final  int sessionType;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  int ackSeqno;
@override@JsonKey() final  String sessionName;
@override@JsonKey() final  bool isPinned;

/// Create a copy of CoreImSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImSessionCopyWith<_CoreImSession> get copyWith => __$CoreImSessionCopyWithImpl<_CoreImSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImSession&&(identical(other.talkerId, talkerId) || other.talkerId == talkerId)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.ackSeqno, ackSeqno) || other.ackSeqno == ackSeqno)&&(identical(other.sessionName, sessionName) || other.sessionName == sessionName)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned));
}


@override
int get hashCode => Object.hash(runtimeType,talkerId,sessionType,unreadCount,ackSeqno,sessionName,isPinned);

@override
String toString() {
  return 'CoreImSession(talkerId: $talkerId, sessionType: $sessionType, unreadCount: $unreadCount, ackSeqno: $ackSeqno, sessionName: $sessionName, isPinned: $isPinned)';
}


}

/// @nodoc
abstract mixin class _$CoreImSessionCopyWith<$Res> implements $CoreImSessionCopyWith<$Res> {
  factory _$CoreImSessionCopyWith(_CoreImSession value, $Res Function(_CoreImSession) _then) = __$CoreImSessionCopyWithImpl;
@override @useResult
$Res call({
 int talkerId, int sessionType, int unreadCount, int ackSeqno, String sessionName, bool isPinned
});




}
/// @nodoc
class __$CoreImSessionCopyWithImpl<$Res>
    implements _$CoreImSessionCopyWith<$Res> {
  __$CoreImSessionCopyWithImpl(this._self, this._then);

  final _CoreImSession _self;
  final $Res Function(_CoreImSession) _then;

/// Create a copy of CoreImSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? talkerId = null,Object? sessionType = null,Object? unreadCount = null,Object? ackSeqno = null,Object? sessionName = null,Object? isPinned = null,}) {
  return _then(_CoreImSession(
talkerId: null == talkerId ? _self.talkerId : talkerId // ignore: cast_nullable_to_non_nullable
as int,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,ackSeqno: null == ackSeqno ? _self.ackSeqno : ackSeqno // ignore: cast_nullable_to_non_nullable
as int,sessionName: null == sessionName ? _self.sessionName : sessionName // ignore: cast_nullable_to_non_nullable
as String,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CoreImKeywordBlockingItem {

 String get keyword; int get id;
/// Create a copy of CoreImKeywordBlockingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImKeywordBlockingItemCopyWith<CoreImKeywordBlockingItem> get copyWith => _$CoreImKeywordBlockingItemCopyWithImpl<CoreImKeywordBlockingItem>(this as CoreImKeywordBlockingItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImKeywordBlockingItem&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,keyword,id);

@override
String toString() {
  return 'CoreImKeywordBlockingItem(keyword: $keyword, id: $id)';
}


}

/// @nodoc
abstract mixin class $CoreImKeywordBlockingItemCopyWith<$Res>  {
  factory $CoreImKeywordBlockingItemCopyWith(CoreImKeywordBlockingItem value, $Res Function(CoreImKeywordBlockingItem) _then) = _$CoreImKeywordBlockingItemCopyWithImpl;
@useResult
$Res call({
 String keyword, int id
});




}
/// @nodoc
class _$CoreImKeywordBlockingItemCopyWithImpl<$Res>
    implements $CoreImKeywordBlockingItemCopyWith<$Res> {
  _$CoreImKeywordBlockingItemCopyWithImpl(this._self, this._then);

  final CoreImKeywordBlockingItem _self;
  final $Res Function(CoreImKeywordBlockingItem) _then;

/// Create a copy of CoreImKeywordBlockingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyword = null,Object? id = null,}) {
  return _then(_self.copyWith(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImKeywordBlockingItem].
extension CoreImKeywordBlockingItemPatterns on CoreImKeywordBlockingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImKeywordBlockingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImKeywordBlockingItem value)  $default,){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImKeywordBlockingItem value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String keyword,  int id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingItem() when $default != null:
return $default(_that.keyword,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String keyword,  int id)  $default,) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingItem():
return $default(_that.keyword,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String keyword,  int id)?  $default,) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingItem() when $default != null:
return $default(_that.keyword,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImKeywordBlockingItem implements CoreImKeywordBlockingItem {
  const _CoreImKeywordBlockingItem({this.keyword = '', this.id = 0});
  

@override@JsonKey() final  String keyword;
@override@JsonKey() final  int id;

/// Create a copy of CoreImKeywordBlockingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImKeywordBlockingItemCopyWith<_CoreImKeywordBlockingItem> get copyWith => __$CoreImKeywordBlockingItemCopyWithImpl<_CoreImKeywordBlockingItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImKeywordBlockingItem&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,keyword,id);

@override
String toString() {
  return 'CoreImKeywordBlockingItem(keyword: $keyword, id: $id)';
}


}

/// @nodoc
abstract mixin class _$CoreImKeywordBlockingItemCopyWith<$Res> implements $CoreImKeywordBlockingItemCopyWith<$Res> {
  factory _$CoreImKeywordBlockingItemCopyWith(_CoreImKeywordBlockingItem value, $Res Function(_CoreImKeywordBlockingItem) _then) = __$CoreImKeywordBlockingItemCopyWithImpl;
@override @useResult
$Res call({
 String keyword, int id
});




}
/// @nodoc
class __$CoreImKeywordBlockingItemCopyWithImpl<$Res>
    implements _$CoreImKeywordBlockingItemCopyWith<$Res> {
  __$CoreImKeywordBlockingItemCopyWithImpl(this._self, this._then);

  final _CoreImKeywordBlockingItem _self;
  final $Res Function(_CoreImKeywordBlockingItem) _then;

/// Create a copy of CoreImKeywordBlockingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyword = null,Object? id = null,}) {
  return _then(_CoreImKeywordBlockingItem(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CoreImRspSendMsg {

 int get msgKey; String get msgContent; int get seqno;
/// Create a copy of CoreImRspSendMsg
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImRspSendMsgCopyWith<CoreImRspSendMsg> get copyWith => _$CoreImRspSendMsgCopyWithImpl<CoreImRspSendMsg>(this as CoreImRspSendMsg, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImRspSendMsg&&(identical(other.msgKey, msgKey) || other.msgKey == msgKey)&&(identical(other.msgContent, msgContent) || other.msgContent == msgContent)&&(identical(other.seqno, seqno) || other.seqno == seqno));
}


@override
int get hashCode => Object.hash(runtimeType,msgKey,msgContent,seqno);

@override
String toString() {
  return 'CoreImRspSendMsg(msgKey: $msgKey, msgContent: $msgContent, seqno: $seqno)';
}


}

/// @nodoc
abstract mixin class $CoreImRspSendMsgCopyWith<$Res>  {
  factory $CoreImRspSendMsgCopyWith(CoreImRspSendMsg value, $Res Function(CoreImRspSendMsg) _then) = _$CoreImRspSendMsgCopyWithImpl;
@useResult
$Res call({
 int msgKey, String msgContent, int seqno
});




}
/// @nodoc
class _$CoreImRspSendMsgCopyWithImpl<$Res>
    implements $CoreImRspSendMsgCopyWith<$Res> {
  _$CoreImRspSendMsgCopyWithImpl(this._self, this._then);

  final CoreImRspSendMsg _self;
  final $Res Function(CoreImRspSendMsg) _then;

/// Create a copy of CoreImRspSendMsg
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? msgKey = null,Object? msgContent = null,Object? seqno = null,}) {
  return _then(_self.copyWith(
msgKey: null == msgKey ? _self.msgKey : msgKey // ignore: cast_nullable_to_non_nullable
as int,msgContent: null == msgContent ? _self.msgContent : msgContent // ignore: cast_nullable_to_non_nullable
as String,seqno: null == seqno ? _self.seqno : seqno // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImRspSendMsg].
extension CoreImRspSendMsgPatterns on CoreImRspSendMsg {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImRspSendMsg value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImRspSendMsg() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImRspSendMsg value)  $default,){
final _that = this;
switch (_that) {
case _CoreImRspSendMsg():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImRspSendMsg value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImRspSendMsg() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int msgKey,  String msgContent,  int seqno)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImRspSendMsg() when $default != null:
return $default(_that.msgKey,_that.msgContent,_that.seqno);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int msgKey,  String msgContent,  int seqno)  $default,) {final _that = this;
switch (_that) {
case _CoreImRspSendMsg():
return $default(_that.msgKey,_that.msgContent,_that.seqno);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int msgKey,  String msgContent,  int seqno)?  $default,) {final _that = this;
switch (_that) {
case _CoreImRspSendMsg() when $default != null:
return $default(_that.msgKey,_that.msgContent,_that.seqno);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImRspSendMsg implements CoreImRspSendMsg {
  const _CoreImRspSendMsg({this.msgKey = 0, this.msgContent = '', this.seqno = 0});
  

@override@JsonKey() final  int msgKey;
@override@JsonKey() final  String msgContent;
@override@JsonKey() final  int seqno;

/// Create a copy of CoreImRspSendMsg
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImRspSendMsgCopyWith<_CoreImRspSendMsg> get copyWith => __$CoreImRspSendMsgCopyWithImpl<_CoreImRspSendMsg>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImRspSendMsg&&(identical(other.msgKey, msgKey) || other.msgKey == msgKey)&&(identical(other.msgContent, msgContent) || other.msgContent == msgContent)&&(identical(other.seqno, seqno) || other.seqno == seqno));
}


@override
int get hashCode => Object.hash(runtimeType,msgKey,msgContent,seqno);

@override
String toString() {
  return 'CoreImRspSendMsg(msgKey: $msgKey, msgContent: $msgContent, seqno: $seqno)';
}


}

/// @nodoc
abstract mixin class _$CoreImRspSendMsgCopyWith<$Res> implements $CoreImRspSendMsgCopyWith<$Res> {
  factory _$CoreImRspSendMsgCopyWith(_CoreImRspSendMsg value, $Res Function(_CoreImRspSendMsg) _then) = __$CoreImRspSendMsgCopyWithImpl;
@override @useResult
$Res call({
 int msgKey, String msgContent, int seqno
});




}
/// @nodoc
class __$CoreImRspSendMsgCopyWithImpl<$Res>
    implements _$CoreImRspSendMsgCopyWith<$Res> {
  __$CoreImRspSendMsgCopyWithImpl(this._self, this._then);

  final _CoreImRspSendMsg _self;
  final $Res Function(_CoreImRspSendMsg) _then;

/// Create a copy of CoreImRspSendMsg
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? msgKey = null,Object? msgContent = null,Object? seqno = null,}) {
  return _then(_CoreImRspSendMsg(
msgKey: null == msgKey ? _self.msgKey : msgKey // ignore: cast_nullable_to_non_nullable
as int,msgContent: null == msgContent ? _self.msgContent : msgContent // ignore: cast_nullable_to_non_nullable
as String,seqno: null == seqno ? _self.seqno : seqno // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CoreImRspShareList {

 List<CoreImShareSessionInfo> get sessionList; int get isAddressListEmpty;
/// Create a copy of CoreImRspShareList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImRspShareListCopyWith<CoreImRspShareList> get copyWith => _$CoreImRspShareListCopyWithImpl<CoreImRspShareList>(this as CoreImRspShareList, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImRspShareList&&const DeepCollectionEquality().equals(other.sessionList, sessionList)&&(identical(other.isAddressListEmpty, isAddressListEmpty) || other.isAddressListEmpty == isAddressListEmpty));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sessionList),isAddressListEmpty);

@override
String toString() {
  return 'CoreImRspShareList(sessionList: $sessionList, isAddressListEmpty: $isAddressListEmpty)';
}


}

/// @nodoc
abstract mixin class $CoreImRspShareListCopyWith<$Res>  {
  factory $CoreImRspShareListCopyWith(CoreImRspShareList value, $Res Function(CoreImRspShareList) _then) = _$CoreImRspShareListCopyWithImpl;
@useResult
$Res call({
 List<CoreImShareSessionInfo> sessionList, int isAddressListEmpty
});




}
/// @nodoc
class _$CoreImRspShareListCopyWithImpl<$Res>
    implements $CoreImRspShareListCopyWith<$Res> {
  _$CoreImRspShareListCopyWithImpl(this._self, this._then);

  final CoreImRspShareList _self;
  final $Res Function(CoreImRspShareList) _then;

/// Create a copy of CoreImRspShareList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionList = null,Object? isAddressListEmpty = null,}) {
  return _then(_self.copyWith(
sessionList: null == sessionList ? _self.sessionList : sessionList // ignore: cast_nullable_to_non_nullable
as List<CoreImShareSessionInfo>,isAddressListEmpty: null == isAddressListEmpty ? _self.isAddressListEmpty : isAddressListEmpty // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImRspShareList].
extension CoreImRspShareListPatterns on CoreImRspShareList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImRspShareList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImRspShareList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImRspShareList value)  $default,){
final _that = this;
switch (_that) {
case _CoreImRspShareList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImRspShareList value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImRspShareList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CoreImShareSessionInfo> sessionList,  int isAddressListEmpty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImRspShareList() when $default != null:
return $default(_that.sessionList,_that.isAddressListEmpty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CoreImShareSessionInfo> sessionList,  int isAddressListEmpty)  $default,) {final _that = this;
switch (_that) {
case _CoreImRspShareList():
return $default(_that.sessionList,_that.isAddressListEmpty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CoreImShareSessionInfo> sessionList,  int isAddressListEmpty)?  $default,) {final _that = this;
switch (_that) {
case _CoreImRspShareList() when $default != null:
return $default(_that.sessionList,_that.isAddressListEmpty);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImRspShareList implements CoreImRspShareList {
  const _CoreImRspShareList({final  List<CoreImShareSessionInfo> sessionList = const [], this.isAddressListEmpty = 0}): _sessionList = sessionList;
  

 final  List<CoreImShareSessionInfo> _sessionList;
@override@JsonKey() List<CoreImShareSessionInfo> get sessionList {
  if (_sessionList is EqualUnmodifiableListView) return _sessionList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessionList);
}

@override@JsonKey() final  int isAddressListEmpty;

/// Create a copy of CoreImRspShareList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImRspShareListCopyWith<_CoreImRspShareList> get copyWith => __$CoreImRspShareListCopyWithImpl<_CoreImRspShareList>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImRspShareList&&const DeepCollectionEquality().equals(other._sessionList, _sessionList)&&(identical(other.isAddressListEmpty, isAddressListEmpty) || other.isAddressListEmpty == isAddressListEmpty));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessionList),isAddressListEmpty);

@override
String toString() {
  return 'CoreImRspShareList(sessionList: $sessionList, isAddressListEmpty: $isAddressListEmpty)';
}


}

/// @nodoc
abstract mixin class _$CoreImRspShareListCopyWith<$Res> implements $CoreImRspShareListCopyWith<$Res> {
  factory _$CoreImRspShareListCopyWith(_CoreImRspShareList value, $Res Function(_CoreImRspShareList) _then) = __$CoreImRspShareListCopyWithImpl;
@override @useResult
$Res call({
 List<CoreImShareSessionInfo> sessionList, int isAddressListEmpty
});




}
/// @nodoc
class __$CoreImRspShareListCopyWithImpl<$Res>
    implements _$CoreImRspShareListCopyWith<$Res> {
  __$CoreImRspShareListCopyWithImpl(this._self, this._then);

  final _CoreImRspShareList _self;
  final $Res Function(_CoreImRspShareList) _then;

/// Create a copy of CoreImRspShareList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionList = null,Object? isAddressListEmpty = null,}) {
  return _then(_CoreImRspShareList(
sessionList: null == sessionList ? _self._sessionList : sessionList // ignore: cast_nullable_to_non_nullable
as List<CoreImShareSessionInfo>,isAddressListEmpty: null == isAddressListEmpty ? _self.isAddressListEmpty : isAddressListEmpty // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CoreImRspSessionMsg {

 List<CoreImMsg> get messages; int get hasMore; int get minSeqno; int get maxSeqno;
/// Create a copy of CoreImRspSessionMsg
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImRspSessionMsgCopyWith<CoreImRspSessionMsg> get copyWith => _$CoreImRspSessionMsgCopyWithImpl<CoreImRspSessionMsg>(this as CoreImRspSessionMsg, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImRspSessionMsg&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.minSeqno, minSeqno) || other.minSeqno == minSeqno)&&(identical(other.maxSeqno, maxSeqno) || other.maxSeqno == maxSeqno));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),hasMore,minSeqno,maxSeqno);

@override
String toString() {
  return 'CoreImRspSessionMsg(messages: $messages, hasMore: $hasMore, minSeqno: $minSeqno, maxSeqno: $maxSeqno)';
}


}

/// @nodoc
abstract mixin class $CoreImRspSessionMsgCopyWith<$Res>  {
  factory $CoreImRspSessionMsgCopyWith(CoreImRspSessionMsg value, $Res Function(CoreImRspSessionMsg) _then) = _$CoreImRspSessionMsgCopyWithImpl;
@useResult
$Res call({
 List<CoreImMsg> messages, int hasMore, int minSeqno, int maxSeqno
});




}
/// @nodoc
class _$CoreImRspSessionMsgCopyWithImpl<$Res>
    implements $CoreImRspSessionMsgCopyWith<$Res> {
  _$CoreImRspSessionMsgCopyWithImpl(this._self, this._then);

  final CoreImRspSessionMsg _self;
  final $Res Function(CoreImRspSessionMsg) _then;

/// Create a copy of CoreImRspSessionMsg
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? hasMore = null,Object? minSeqno = null,Object? maxSeqno = null,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<CoreImMsg>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as int,minSeqno: null == minSeqno ? _self.minSeqno : minSeqno // ignore: cast_nullable_to_non_nullable
as int,maxSeqno: null == maxSeqno ? _self.maxSeqno : maxSeqno // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImRspSessionMsg].
extension CoreImRspSessionMsgPatterns on CoreImRspSessionMsg {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImRspSessionMsg value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImRspSessionMsg() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImRspSessionMsg value)  $default,){
final _that = this;
switch (_that) {
case _CoreImRspSessionMsg():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImRspSessionMsg value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImRspSessionMsg() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CoreImMsg> messages,  int hasMore,  int minSeqno,  int maxSeqno)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImRspSessionMsg() when $default != null:
return $default(_that.messages,_that.hasMore,_that.minSeqno,_that.maxSeqno);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CoreImMsg> messages,  int hasMore,  int minSeqno,  int maxSeqno)  $default,) {final _that = this;
switch (_that) {
case _CoreImRspSessionMsg():
return $default(_that.messages,_that.hasMore,_that.minSeqno,_that.maxSeqno);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CoreImMsg> messages,  int hasMore,  int minSeqno,  int maxSeqno)?  $default,) {final _that = this;
switch (_that) {
case _CoreImRspSessionMsg() when $default != null:
return $default(_that.messages,_that.hasMore,_that.minSeqno,_that.maxSeqno);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImRspSessionMsg implements CoreImRspSessionMsg {
  const _CoreImRspSessionMsg({final  List<CoreImMsg> messages = const [], this.hasMore = 0, this.minSeqno = 0, this.maxSeqno = 0}): _messages = messages;
  

 final  List<CoreImMsg> _messages;
@override@JsonKey() List<CoreImMsg> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  int hasMore;
@override@JsonKey() final  int minSeqno;
@override@JsonKey() final  int maxSeqno;

/// Create a copy of CoreImRspSessionMsg
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImRspSessionMsgCopyWith<_CoreImRspSessionMsg> get copyWith => __$CoreImRspSessionMsgCopyWithImpl<_CoreImRspSessionMsg>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImRspSessionMsg&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.minSeqno, minSeqno) || other.minSeqno == minSeqno)&&(identical(other.maxSeqno, maxSeqno) || other.maxSeqno == maxSeqno));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),hasMore,minSeqno,maxSeqno);

@override
String toString() {
  return 'CoreImRspSessionMsg(messages: $messages, hasMore: $hasMore, minSeqno: $minSeqno, maxSeqno: $maxSeqno)';
}


}

/// @nodoc
abstract mixin class _$CoreImRspSessionMsgCopyWith<$Res> implements $CoreImRspSessionMsgCopyWith<$Res> {
  factory _$CoreImRspSessionMsgCopyWith(_CoreImRspSessionMsg value, $Res Function(_CoreImRspSessionMsg) _then) = __$CoreImRspSessionMsgCopyWithImpl;
@override @useResult
$Res call({
 List<CoreImMsg> messages, int hasMore, int minSeqno, int maxSeqno
});




}
/// @nodoc
class __$CoreImRspSessionMsgCopyWithImpl<$Res>
    implements _$CoreImRspSessionMsgCopyWith<$Res> {
  __$CoreImRspSessionMsgCopyWithImpl(this._self, this._then);

  final _CoreImRspSessionMsg _self;
  final $Res Function(_CoreImRspSessionMsg) _then;

/// Create a copy of CoreImRspSessionMsg
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? hasMore = null,Object? minSeqno = null,Object? maxSeqno = null,}) {
  return _then(_CoreImRspSessionMsg(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<CoreImMsg>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as int,minSeqno: null == minSeqno ? _self.minSeqno : minSeqno // ignore: cast_nullable_to_non_nullable
as int,maxSeqno: null == maxSeqno ? _self.maxSeqno : maxSeqno // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CoreImSessionMainReply {

 bool get hasMore; List<CoreImSession> get sessions;
/// Create a copy of CoreImSessionMainReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImSessionMainReplyCopyWith<CoreImSessionMainReply> get copyWith => _$CoreImSessionMainReplyCopyWithImpl<CoreImSessionMainReply>(this as CoreImSessionMainReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImSessionMainReply&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&const DeepCollectionEquality().equals(other.sessions, sessions));
}


@override
int get hashCode => Object.hash(runtimeType,hasMore,const DeepCollectionEquality().hash(sessions));

@override
String toString() {
  return 'CoreImSessionMainReply(hasMore: $hasMore, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class $CoreImSessionMainReplyCopyWith<$Res>  {
  factory $CoreImSessionMainReplyCopyWith(CoreImSessionMainReply value, $Res Function(CoreImSessionMainReply) _then) = _$CoreImSessionMainReplyCopyWithImpl;
@useResult
$Res call({
 bool hasMore, List<CoreImSession> sessions
});




}
/// @nodoc
class _$CoreImSessionMainReplyCopyWithImpl<$Res>
    implements $CoreImSessionMainReplyCopyWith<$Res> {
  _$CoreImSessionMainReplyCopyWithImpl(this._self, this._then);

  final CoreImSessionMainReply _self;
  final $Res Function(CoreImSessionMainReply) _then;

/// Create a copy of CoreImSessionMainReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasMore = null,Object? sessions = null,}) {
  return _then(_self.copyWith(
hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<CoreImSession>,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImSessionMainReply].
extension CoreImSessionMainReplyPatterns on CoreImSessionMainReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImSessionMainReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImSessionMainReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImSessionMainReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionMainReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImSessionMainReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionMainReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasMore,  List<CoreImSession> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImSessionMainReply() when $default != null:
return $default(_that.hasMore,_that.sessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasMore,  List<CoreImSession> sessions)  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionMainReply():
return $default(_that.hasMore,_that.sessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasMore,  List<CoreImSession> sessions)?  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionMainReply() when $default != null:
return $default(_that.hasMore,_that.sessions);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImSessionMainReply implements CoreImSessionMainReply {
  const _CoreImSessionMainReply({this.hasMore = false, final  List<CoreImSession> sessions = const []}): _sessions = sessions;
  

@override@JsonKey() final  bool hasMore;
 final  List<CoreImSession> _sessions;
@override@JsonKey() List<CoreImSession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}


/// Create a copy of CoreImSessionMainReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImSessionMainReplyCopyWith<_CoreImSessionMainReply> get copyWith => __$CoreImSessionMainReplyCopyWithImpl<_CoreImSessionMainReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImSessionMainReply&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&const DeepCollectionEquality().equals(other._sessions, _sessions));
}


@override
int get hashCode => Object.hash(runtimeType,hasMore,const DeepCollectionEquality().hash(_sessions));

@override
String toString() {
  return 'CoreImSessionMainReply(hasMore: $hasMore, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$CoreImSessionMainReplyCopyWith<$Res> implements $CoreImSessionMainReplyCopyWith<$Res> {
  factory _$CoreImSessionMainReplyCopyWith(_CoreImSessionMainReply value, $Res Function(_CoreImSessionMainReply) _then) = __$CoreImSessionMainReplyCopyWithImpl;
@override @useResult
$Res call({
 bool hasMore, List<CoreImSession> sessions
});




}
/// @nodoc
class __$CoreImSessionMainReplyCopyWithImpl<$Res>
    implements _$CoreImSessionMainReplyCopyWith<$Res> {
  __$CoreImSessionMainReplyCopyWithImpl(this._self, this._then);

  final _CoreImSessionMainReply _self;
  final $Res Function(_CoreImSessionMainReply) _then;

/// Create a copy of CoreImSessionMainReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasMore = null,Object? sessions = null,}) {
  return _then(_CoreImSessionMainReply(
hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<CoreImSession>,
  ));
}


}

/// @nodoc
mixin _$CoreImSessionSecondaryReply {

 bool get hasMore; List<CoreImSession> get sessions;
/// Create a copy of CoreImSessionSecondaryReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImSessionSecondaryReplyCopyWith<CoreImSessionSecondaryReply> get copyWith => _$CoreImSessionSecondaryReplyCopyWithImpl<CoreImSessionSecondaryReply>(this as CoreImSessionSecondaryReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImSessionSecondaryReply&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&const DeepCollectionEquality().equals(other.sessions, sessions));
}


@override
int get hashCode => Object.hash(runtimeType,hasMore,const DeepCollectionEquality().hash(sessions));

@override
String toString() {
  return 'CoreImSessionSecondaryReply(hasMore: $hasMore, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class $CoreImSessionSecondaryReplyCopyWith<$Res>  {
  factory $CoreImSessionSecondaryReplyCopyWith(CoreImSessionSecondaryReply value, $Res Function(CoreImSessionSecondaryReply) _then) = _$CoreImSessionSecondaryReplyCopyWithImpl;
@useResult
$Res call({
 bool hasMore, List<CoreImSession> sessions
});




}
/// @nodoc
class _$CoreImSessionSecondaryReplyCopyWithImpl<$Res>
    implements $CoreImSessionSecondaryReplyCopyWith<$Res> {
  _$CoreImSessionSecondaryReplyCopyWithImpl(this._self, this._then);

  final CoreImSessionSecondaryReply _self;
  final $Res Function(CoreImSessionSecondaryReply) _then;

/// Create a copy of CoreImSessionSecondaryReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasMore = null,Object? sessions = null,}) {
  return _then(_self.copyWith(
hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<CoreImSession>,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImSessionSecondaryReply].
extension CoreImSessionSecondaryReplyPatterns on CoreImSessionSecondaryReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImSessionSecondaryReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImSessionSecondaryReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImSessionSecondaryReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionSecondaryReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImSessionSecondaryReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionSecondaryReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasMore,  List<CoreImSession> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImSessionSecondaryReply() when $default != null:
return $default(_that.hasMore,_that.sessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasMore,  List<CoreImSession> sessions)  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionSecondaryReply():
return $default(_that.hasMore,_that.sessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasMore,  List<CoreImSession> sessions)?  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionSecondaryReply() when $default != null:
return $default(_that.hasMore,_that.sessions);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImSessionSecondaryReply implements CoreImSessionSecondaryReply {
  const _CoreImSessionSecondaryReply({this.hasMore = false, final  List<CoreImSession> sessions = const []}): _sessions = sessions;
  

@override@JsonKey() final  bool hasMore;
 final  List<CoreImSession> _sessions;
@override@JsonKey() List<CoreImSession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}


/// Create a copy of CoreImSessionSecondaryReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImSessionSecondaryReplyCopyWith<_CoreImSessionSecondaryReply> get copyWith => __$CoreImSessionSecondaryReplyCopyWithImpl<_CoreImSessionSecondaryReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImSessionSecondaryReply&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&const DeepCollectionEquality().equals(other._sessions, _sessions));
}


@override
int get hashCode => Object.hash(runtimeType,hasMore,const DeepCollectionEquality().hash(_sessions));

@override
String toString() {
  return 'CoreImSessionSecondaryReply(hasMore: $hasMore, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$CoreImSessionSecondaryReplyCopyWith<$Res> implements $CoreImSessionSecondaryReplyCopyWith<$Res> {
  factory _$CoreImSessionSecondaryReplyCopyWith(_CoreImSessionSecondaryReply value, $Res Function(_CoreImSessionSecondaryReply) _then) = __$CoreImSessionSecondaryReplyCopyWithImpl;
@override @useResult
$Res call({
 bool hasMore, List<CoreImSession> sessions
});




}
/// @nodoc
class __$CoreImSessionSecondaryReplyCopyWithImpl<$Res>
    implements _$CoreImSessionSecondaryReplyCopyWith<$Res> {
  __$CoreImSessionSecondaryReplyCopyWithImpl(this._self, this._then);

  final _CoreImSessionSecondaryReply _self;
  final $Res Function(_CoreImSessionSecondaryReply) _then;

/// Create a copy of CoreImSessionSecondaryReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasMore = null,Object? sessions = null,}) {
  return _then(_CoreImSessionSecondaryReply(
hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<CoreImSession>,
  ));
}


}

/// @nodoc
mixin _$CoreImClearUnreadReply {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImClearUnreadReply);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CoreImClearUnreadReply()';
}


}

/// @nodoc
class $CoreImClearUnreadReplyCopyWith<$Res>  {
$CoreImClearUnreadReplyCopyWith(CoreImClearUnreadReply _, $Res Function(CoreImClearUnreadReply) __);
}


/// Adds pattern-matching-related methods to [CoreImClearUnreadReply].
extension CoreImClearUnreadReplyPatterns on CoreImClearUnreadReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImClearUnreadReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImClearUnreadReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImClearUnreadReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImClearUnreadReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImClearUnreadReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImClearUnreadReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function()?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImClearUnreadReply() when $default != null:
return $default();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function()  $default,) {final _that = this;
switch (_that) {
case _CoreImClearUnreadReply():
return $default();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function()?  $default,) {final _that = this;
switch (_that) {
case _CoreImClearUnreadReply() when $default != null:
return $default();case _:
  return null;

}
}

}

/// @nodoc


class _CoreImClearUnreadReply implements CoreImClearUnreadReply {
  const _CoreImClearUnreadReply();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImClearUnreadReply);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CoreImClearUnreadReply()';
}


}




/// @nodoc
mixin _$CoreImSessionUpdateReply {

 CoreImSession? get session;
/// Create a copy of CoreImSessionUpdateReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImSessionUpdateReplyCopyWith<CoreImSessionUpdateReply> get copyWith => _$CoreImSessionUpdateReplyCopyWithImpl<CoreImSessionUpdateReply>(this as CoreImSessionUpdateReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImSessionUpdateReply&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,session);

@override
String toString() {
  return 'CoreImSessionUpdateReply(session: $session)';
}


}

/// @nodoc
abstract mixin class $CoreImSessionUpdateReplyCopyWith<$Res>  {
  factory $CoreImSessionUpdateReplyCopyWith(CoreImSessionUpdateReply value, $Res Function(CoreImSessionUpdateReply) _then) = _$CoreImSessionUpdateReplyCopyWithImpl;
@useResult
$Res call({
 CoreImSession? session
});


$CoreImSessionCopyWith<$Res>? get session;

}
/// @nodoc
class _$CoreImSessionUpdateReplyCopyWithImpl<$Res>
    implements $CoreImSessionUpdateReplyCopyWith<$Res> {
  _$CoreImSessionUpdateReplyCopyWithImpl(this._self, this._then);

  final CoreImSessionUpdateReply _self;
  final $Res Function(CoreImSessionUpdateReply) _then;

/// Create a copy of CoreImSessionUpdateReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? session = freezed,}) {
  return _then(_self.copyWith(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as CoreImSession?,
  ));
}
/// Create a copy of CoreImSessionUpdateReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreImSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $CoreImSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [CoreImSessionUpdateReply].
extension CoreImSessionUpdateReplyPatterns on CoreImSessionUpdateReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImSessionUpdateReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImSessionUpdateReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImSessionUpdateReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionUpdateReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImSessionUpdateReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionUpdateReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CoreImSession? session)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImSessionUpdateReply() when $default != null:
return $default(_that.session);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CoreImSession? session)  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionUpdateReply():
return $default(_that.session);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CoreImSession? session)?  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionUpdateReply() when $default != null:
return $default(_that.session);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImSessionUpdateReply implements CoreImSessionUpdateReply {
  const _CoreImSessionUpdateReply({this.session});
  

@override final  CoreImSession? session;

/// Create a copy of CoreImSessionUpdateReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImSessionUpdateReplyCopyWith<_CoreImSessionUpdateReply> get copyWith => __$CoreImSessionUpdateReplyCopyWithImpl<_CoreImSessionUpdateReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImSessionUpdateReply&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,session);

@override
String toString() {
  return 'CoreImSessionUpdateReply(session: $session)';
}


}

/// @nodoc
abstract mixin class _$CoreImSessionUpdateReplyCopyWith<$Res> implements $CoreImSessionUpdateReplyCopyWith<$Res> {
  factory _$CoreImSessionUpdateReplyCopyWith(_CoreImSessionUpdateReply value, $Res Function(_CoreImSessionUpdateReply) _then) = __$CoreImSessionUpdateReplyCopyWithImpl;
@override @useResult
$Res call({
 CoreImSession? session
});


@override $CoreImSessionCopyWith<$Res>? get session;

}
/// @nodoc
class __$CoreImSessionUpdateReplyCopyWithImpl<$Res>
    implements _$CoreImSessionUpdateReplyCopyWith<$Res> {
  __$CoreImSessionUpdateReplyCopyWithImpl(this._self, this._then);

  final _CoreImSessionUpdateReply _self;
  final $Res Function(_CoreImSessionUpdateReply) _then;

/// Create a copy of CoreImSessionUpdateReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = freezed,}) {
  return _then(_CoreImSessionUpdateReply(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as CoreImSession?,
  ));
}

/// Create a copy of CoreImSessionUpdateReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreImSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $CoreImSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc
mixin _$CoreImPinSessionReply {

 int get sequenceNumber; int get code; String get message;
/// Create a copy of CoreImPinSessionReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImPinSessionReplyCopyWith<CoreImPinSessionReply> get copyWith => _$CoreImPinSessionReplyCopyWithImpl<CoreImPinSessionReply>(this as CoreImPinSessionReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImPinSessionReply&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,sequenceNumber,code,message);

@override
String toString() {
  return 'CoreImPinSessionReply(sequenceNumber: $sequenceNumber, code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $CoreImPinSessionReplyCopyWith<$Res>  {
  factory $CoreImPinSessionReplyCopyWith(CoreImPinSessionReply value, $Res Function(CoreImPinSessionReply) _then) = _$CoreImPinSessionReplyCopyWithImpl;
@useResult
$Res call({
 int sequenceNumber, int code, String message
});




}
/// @nodoc
class _$CoreImPinSessionReplyCopyWithImpl<$Res>
    implements $CoreImPinSessionReplyCopyWith<$Res> {
  _$CoreImPinSessionReplyCopyWithImpl(this._self, this._then);

  final CoreImPinSessionReply _self;
  final $Res Function(CoreImPinSessionReply) _then;

/// Create a copy of CoreImPinSessionReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sequenceNumber = null,Object? code = null,Object? message = null,}) {
  return _then(_self.copyWith(
sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImPinSessionReply].
extension CoreImPinSessionReplyPatterns on CoreImPinSessionReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImPinSessionReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImPinSessionReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImPinSessionReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImPinSessionReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImPinSessionReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImPinSessionReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sequenceNumber,  int code,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImPinSessionReply() when $default != null:
return $default(_that.sequenceNumber,_that.code,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sequenceNumber,  int code,  String message)  $default,) {final _that = this;
switch (_that) {
case _CoreImPinSessionReply():
return $default(_that.sequenceNumber,_that.code,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sequenceNumber,  int code,  String message)?  $default,) {final _that = this;
switch (_that) {
case _CoreImPinSessionReply() when $default != null:
return $default(_that.sequenceNumber,_that.code,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImPinSessionReply implements CoreImPinSessionReply {
  const _CoreImPinSessionReply({this.sequenceNumber = 0, this.code = 0, this.message = ''});
  

@override@JsonKey() final  int sequenceNumber;
@override@JsonKey() final  int code;
@override@JsonKey() final  String message;

/// Create a copy of CoreImPinSessionReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImPinSessionReplyCopyWith<_CoreImPinSessionReply> get copyWith => __$CoreImPinSessionReplyCopyWithImpl<_CoreImPinSessionReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImPinSessionReply&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,sequenceNumber,code,message);

@override
String toString() {
  return 'CoreImPinSessionReply(sequenceNumber: $sequenceNumber, code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CoreImPinSessionReplyCopyWith<$Res> implements $CoreImPinSessionReplyCopyWith<$Res> {
  factory _$CoreImPinSessionReplyCopyWith(_CoreImPinSessionReply value, $Res Function(_CoreImPinSessionReply) _then) = __$CoreImPinSessionReplyCopyWithImpl;
@override @useResult
$Res call({
 int sequenceNumber, int code, String message
});




}
/// @nodoc
class __$CoreImPinSessionReplyCopyWithImpl<$Res>
    implements _$CoreImPinSessionReplyCopyWith<$Res> {
  __$CoreImPinSessionReplyCopyWithImpl(this._self, this._then);

  final _CoreImPinSessionReply _self;
  final $Res Function(_CoreImPinSessionReply) _then;

/// Create a copy of CoreImPinSessionReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sequenceNumber = null,Object? code = null,Object? message = null,}) {
  return _then(_CoreImPinSessionReply(
sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CoreImUnPinSessionReply {

 int get sequenceNumber;
/// Create a copy of CoreImUnPinSessionReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImUnPinSessionReplyCopyWith<CoreImUnPinSessionReply> get copyWith => _$CoreImUnPinSessionReplyCopyWithImpl<CoreImUnPinSessionReply>(this as CoreImUnPinSessionReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImUnPinSessionReply&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber));
}


@override
int get hashCode => Object.hash(runtimeType,sequenceNumber);

@override
String toString() {
  return 'CoreImUnPinSessionReply(sequenceNumber: $sequenceNumber)';
}


}

/// @nodoc
abstract mixin class $CoreImUnPinSessionReplyCopyWith<$Res>  {
  factory $CoreImUnPinSessionReplyCopyWith(CoreImUnPinSessionReply value, $Res Function(CoreImUnPinSessionReply) _then) = _$CoreImUnPinSessionReplyCopyWithImpl;
@useResult
$Res call({
 int sequenceNumber
});




}
/// @nodoc
class _$CoreImUnPinSessionReplyCopyWithImpl<$Res>
    implements $CoreImUnPinSessionReplyCopyWith<$Res> {
  _$CoreImUnPinSessionReplyCopyWithImpl(this._self, this._then);

  final CoreImUnPinSessionReply _self;
  final $Res Function(CoreImUnPinSessionReply) _then;

/// Create a copy of CoreImUnPinSessionReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sequenceNumber = null,}) {
  return _then(_self.copyWith(
sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImUnPinSessionReply].
extension CoreImUnPinSessionReplyPatterns on CoreImUnPinSessionReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImUnPinSessionReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImUnPinSessionReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImUnPinSessionReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImUnPinSessionReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImUnPinSessionReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImUnPinSessionReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sequenceNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImUnPinSessionReply() when $default != null:
return $default(_that.sequenceNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sequenceNumber)  $default,) {final _that = this;
switch (_that) {
case _CoreImUnPinSessionReply():
return $default(_that.sequenceNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sequenceNumber)?  $default,) {final _that = this;
switch (_that) {
case _CoreImUnPinSessionReply() when $default != null:
return $default(_that.sequenceNumber);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImUnPinSessionReply implements CoreImUnPinSessionReply {
  const _CoreImUnPinSessionReply({this.sequenceNumber = 0});
  

@override@JsonKey() final  int sequenceNumber;

/// Create a copy of CoreImUnPinSessionReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImUnPinSessionReplyCopyWith<_CoreImUnPinSessionReply> get copyWith => __$CoreImUnPinSessionReplyCopyWithImpl<_CoreImUnPinSessionReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImUnPinSessionReply&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber));
}


@override
int get hashCode => Object.hash(runtimeType,sequenceNumber);

@override
String toString() {
  return 'CoreImUnPinSessionReply(sequenceNumber: $sequenceNumber)';
}


}

/// @nodoc
abstract mixin class _$CoreImUnPinSessionReplyCopyWith<$Res> implements $CoreImUnPinSessionReplyCopyWith<$Res> {
  factory _$CoreImUnPinSessionReplyCopyWith(_CoreImUnPinSessionReply value, $Res Function(_CoreImUnPinSessionReply) _then) = __$CoreImUnPinSessionReplyCopyWithImpl;
@override @useResult
$Res call({
 int sequenceNumber
});




}
/// @nodoc
class __$CoreImUnPinSessionReplyCopyWithImpl<$Res>
    implements _$CoreImUnPinSessionReplyCopyWith<$Res> {
  __$CoreImUnPinSessionReplyCopyWithImpl(this._self, this._then);

  final _CoreImUnPinSessionReply _self;
  final $Res Function(_CoreImUnPinSessionReply) _then;

/// Create a copy of CoreImUnPinSessionReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sequenceNumber = null,}) {
  return _then(_CoreImUnPinSessionReply(
sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CoreImDeleteSessionListReply {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImDeleteSessionListReply);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CoreImDeleteSessionListReply()';
}


}

/// @nodoc
class $CoreImDeleteSessionListReplyCopyWith<$Res>  {
$CoreImDeleteSessionListReplyCopyWith(CoreImDeleteSessionListReply _, $Res Function(CoreImDeleteSessionListReply) __);
}


/// Adds pattern-matching-related methods to [CoreImDeleteSessionListReply].
extension CoreImDeleteSessionListReplyPatterns on CoreImDeleteSessionListReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImDeleteSessionListReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImDeleteSessionListReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImDeleteSessionListReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImDeleteSessionListReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImDeleteSessionListReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImDeleteSessionListReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function()?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImDeleteSessionListReply() when $default != null:
return $default();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function()  $default,) {final _that = this;
switch (_that) {
case _CoreImDeleteSessionListReply():
return $default();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function()?  $default,) {final _that = this;
switch (_that) {
case _CoreImDeleteSessionListReply() when $default != null:
return $default();case _:
  return null;

}
}

}

/// @nodoc


class _CoreImDeleteSessionListReply implements CoreImDeleteSessionListReply {
  const _CoreImDeleteSessionListReply();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImDeleteSessionListReply);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CoreImDeleteSessionListReply()';
}


}




/// @nodoc
mixin _$CoreImGetImSettingsReply {

 String get pageTitle; Map<int, CoreImSetting> get settings;
/// Create a copy of CoreImGetImSettingsReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImGetImSettingsReplyCopyWith<CoreImGetImSettingsReply> get copyWith => _$CoreImGetImSettingsReplyCopyWithImpl<CoreImGetImSettingsReply>(this as CoreImGetImSettingsReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImGetImSettingsReply&&(identical(other.pageTitle, pageTitle) || other.pageTitle == pageTitle)&&const DeepCollectionEquality().equals(other.settings, settings));
}


@override
int get hashCode => Object.hash(runtimeType,pageTitle,const DeepCollectionEquality().hash(settings));

@override
String toString() {
  return 'CoreImGetImSettingsReply(pageTitle: $pageTitle, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $CoreImGetImSettingsReplyCopyWith<$Res>  {
  factory $CoreImGetImSettingsReplyCopyWith(CoreImGetImSettingsReply value, $Res Function(CoreImGetImSettingsReply) _then) = _$CoreImGetImSettingsReplyCopyWithImpl;
@useResult
$Res call({
 String pageTitle, Map<int, CoreImSetting> settings
});




}
/// @nodoc
class _$CoreImGetImSettingsReplyCopyWithImpl<$Res>
    implements $CoreImGetImSettingsReplyCopyWith<$Res> {
  _$CoreImGetImSettingsReplyCopyWithImpl(this._self, this._then);

  final CoreImGetImSettingsReply _self;
  final $Res Function(CoreImGetImSettingsReply) _then;

/// Create a copy of CoreImGetImSettingsReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageTitle = null,Object? settings = null,}) {
  return _then(_self.copyWith(
pageTitle: null == pageTitle ? _self.pageTitle : pageTitle // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<int, CoreImSetting>,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImGetImSettingsReply].
extension CoreImGetImSettingsReplyPatterns on CoreImGetImSettingsReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImGetImSettingsReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImGetImSettingsReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImGetImSettingsReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImGetImSettingsReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImGetImSettingsReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImGetImSettingsReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pageTitle,  Map<int, CoreImSetting> settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImGetImSettingsReply() when $default != null:
return $default(_that.pageTitle,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pageTitle,  Map<int, CoreImSetting> settings)  $default,) {final _that = this;
switch (_that) {
case _CoreImGetImSettingsReply():
return $default(_that.pageTitle,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pageTitle,  Map<int, CoreImSetting> settings)?  $default,) {final _that = this;
switch (_that) {
case _CoreImGetImSettingsReply() when $default != null:
return $default(_that.pageTitle,_that.settings);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImGetImSettingsReply implements CoreImGetImSettingsReply {
  const _CoreImGetImSettingsReply({this.pageTitle = '', final  Map<int, CoreImSetting> settings = const {}}): _settings = settings;
  

@override@JsonKey() final  String pageTitle;
 final  Map<int, CoreImSetting> _settings;
@override@JsonKey() Map<int, CoreImSetting> get settings {
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settings);
}


/// Create a copy of CoreImGetImSettingsReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImGetImSettingsReplyCopyWith<_CoreImGetImSettingsReply> get copyWith => __$CoreImGetImSettingsReplyCopyWithImpl<_CoreImGetImSettingsReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImGetImSettingsReply&&(identical(other.pageTitle, pageTitle) || other.pageTitle == pageTitle)&&const DeepCollectionEquality().equals(other._settings, _settings));
}


@override
int get hashCode => Object.hash(runtimeType,pageTitle,const DeepCollectionEquality().hash(_settings));

@override
String toString() {
  return 'CoreImGetImSettingsReply(pageTitle: $pageTitle, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$CoreImGetImSettingsReplyCopyWith<$Res> implements $CoreImGetImSettingsReplyCopyWith<$Res> {
  factory _$CoreImGetImSettingsReplyCopyWith(_CoreImGetImSettingsReply value, $Res Function(_CoreImGetImSettingsReply) _then) = __$CoreImGetImSettingsReplyCopyWithImpl;
@override @useResult
$Res call({
 String pageTitle, Map<int, CoreImSetting> settings
});




}
/// @nodoc
class __$CoreImGetImSettingsReplyCopyWithImpl<$Res>
    implements _$CoreImGetImSettingsReplyCopyWith<$Res> {
  __$CoreImGetImSettingsReplyCopyWithImpl(this._self, this._then);

  final _CoreImGetImSettingsReply _self;
  final $Res Function(_CoreImGetImSettingsReply) _then;

/// Create a copy of CoreImGetImSettingsReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageTitle = null,Object? settings = null,}) {
  return _then(_CoreImGetImSettingsReply(
pageTitle: null == pageTitle ? _self.pageTitle : pageTitle // ignore: cast_nullable_to_non_nullable
as String,settings: null == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<int, CoreImSetting>,
  ));
}


}

/// @nodoc
mixin _$CoreImSetImSettingsReply {

 String get toast;
/// Create a copy of CoreImSetImSettingsReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImSetImSettingsReplyCopyWith<CoreImSetImSettingsReply> get copyWith => _$CoreImSetImSettingsReplyCopyWithImpl<CoreImSetImSettingsReply>(this as CoreImSetImSettingsReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImSetImSettingsReply&&(identical(other.toast, toast) || other.toast == toast));
}


@override
int get hashCode => Object.hash(runtimeType,toast);

@override
String toString() {
  return 'CoreImSetImSettingsReply(toast: $toast)';
}


}

/// @nodoc
abstract mixin class $CoreImSetImSettingsReplyCopyWith<$Res>  {
  factory $CoreImSetImSettingsReplyCopyWith(CoreImSetImSettingsReply value, $Res Function(CoreImSetImSettingsReply) _then) = _$CoreImSetImSettingsReplyCopyWithImpl;
@useResult
$Res call({
 String toast
});




}
/// @nodoc
class _$CoreImSetImSettingsReplyCopyWithImpl<$Res>
    implements $CoreImSetImSettingsReplyCopyWith<$Res> {
  _$CoreImSetImSettingsReplyCopyWithImpl(this._self, this._then);

  final CoreImSetImSettingsReply _self;
  final $Res Function(CoreImSetImSettingsReply) _then;

/// Create a copy of CoreImSetImSettingsReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? toast = null,}) {
  return _then(_self.copyWith(
toast: null == toast ? _self.toast : toast // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImSetImSettingsReply].
extension CoreImSetImSettingsReplyPatterns on CoreImSetImSettingsReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImSetImSettingsReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImSetImSettingsReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImSetImSettingsReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImSetImSettingsReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImSetImSettingsReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImSetImSettingsReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String toast)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImSetImSettingsReply() when $default != null:
return $default(_that.toast);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String toast)  $default,) {final _that = this;
switch (_that) {
case _CoreImSetImSettingsReply():
return $default(_that.toast);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String toast)?  $default,) {final _that = this;
switch (_that) {
case _CoreImSetImSettingsReply() when $default != null:
return $default(_that.toast);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImSetImSettingsReply implements CoreImSetImSettingsReply {
  const _CoreImSetImSettingsReply({this.toast = ''});
  

@override@JsonKey() final  String toast;

/// Create a copy of CoreImSetImSettingsReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImSetImSettingsReplyCopyWith<_CoreImSetImSettingsReply> get copyWith => __$CoreImSetImSettingsReplyCopyWithImpl<_CoreImSetImSettingsReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImSetImSettingsReply&&(identical(other.toast, toast) || other.toast == toast));
}


@override
int get hashCode => Object.hash(runtimeType,toast);

@override
String toString() {
  return 'CoreImSetImSettingsReply(toast: $toast)';
}


}

/// @nodoc
abstract mixin class _$CoreImSetImSettingsReplyCopyWith<$Res> implements $CoreImSetImSettingsReplyCopyWith<$Res> {
  factory _$CoreImSetImSettingsReplyCopyWith(_CoreImSetImSettingsReply value, $Res Function(_CoreImSetImSettingsReply) _then) = __$CoreImSetImSettingsReplyCopyWithImpl;
@override @useResult
$Res call({
 String toast
});




}
/// @nodoc
class __$CoreImSetImSettingsReplyCopyWithImpl<$Res>
    implements _$CoreImSetImSettingsReplyCopyWith<$Res> {
  __$CoreImSetImSettingsReplyCopyWithImpl(this._self, this._then);

  final _CoreImSetImSettingsReply _self;
  final $Res Function(_CoreImSetImSettingsReply) _then;

/// Create a copy of CoreImSetImSettingsReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toast = null,}) {
  return _then(_CoreImSetImSettingsReply(
toast: null == toast ? _self.toast : toast // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CoreImKeywordBlockingListReply {

 List<CoreImKeywordBlockingItem> get items; int get listLimit; int get charLimit; String get listLimitText;
/// Create a copy of CoreImKeywordBlockingListReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImKeywordBlockingListReplyCopyWith<CoreImKeywordBlockingListReply> get copyWith => _$CoreImKeywordBlockingListReplyCopyWithImpl<CoreImKeywordBlockingListReply>(this as CoreImKeywordBlockingListReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImKeywordBlockingListReply&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.listLimit, listLimit) || other.listLimit == listLimit)&&(identical(other.charLimit, charLimit) || other.charLimit == charLimit)&&(identical(other.listLimitText, listLimitText) || other.listLimitText == listLimitText));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),listLimit,charLimit,listLimitText);

@override
String toString() {
  return 'CoreImKeywordBlockingListReply(items: $items, listLimit: $listLimit, charLimit: $charLimit, listLimitText: $listLimitText)';
}


}

/// @nodoc
abstract mixin class $CoreImKeywordBlockingListReplyCopyWith<$Res>  {
  factory $CoreImKeywordBlockingListReplyCopyWith(CoreImKeywordBlockingListReply value, $Res Function(CoreImKeywordBlockingListReply) _then) = _$CoreImKeywordBlockingListReplyCopyWithImpl;
@useResult
$Res call({
 List<CoreImKeywordBlockingItem> items, int listLimit, int charLimit, String listLimitText
});




}
/// @nodoc
class _$CoreImKeywordBlockingListReplyCopyWithImpl<$Res>
    implements $CoreImKeywordBlockingListReplyCopyWith<$Res> {
  _$CoreImKeywordBlockingListReplyCopyWithImpl(this._self, this._then);

  final CoreImKeywordBlockingListReply _self;
  final $Res Function(CoreImKeywordBlockingListReply) _then;

/// Create a copy of CoreImKeywordBlockingListReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? listLimit = null,Object? charLimit = null,Object? listLimitText = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CoreImKeywordBlockingItem>,listLimit: null == listLimit ? _self.listLimit : listLimit // ignore: cast_nullable_to_non_nullable
as int,charLimit: null == charLimit ? _self.charLimit : charLimit // ignore: cast_nullable_to_non_nullable
as int,listLimitText: null == listLimitText ? _self.listLimitText : listLimitText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImKeywordBlockingListReply].
extension CoreImKeywordBlockingListReplyPatterns on CoreImKeywordBlockingListReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImKeywordBlockingListReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingListReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImKeywordBlockingListReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingListReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImKeywordBlockingListReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingListReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CoreImKeywordBlockingItem> items,  int listLimit,  int charLimit,  String listLimitText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingListReply() when $default != null:
return $default(_that.items,_that.listLimit,_that.charLimit,_that.listLimitText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CoreImKeywordBlockingItem> items,  int listLimit,  int charLimit,  String listLimitText)  $default,) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingListReply():
return $default(_that.items,_that.listLimit,_that.charLimit,_that.listLimitText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CoreImKeywordBlockingItem> items,  int listLimit,  int charLimit,  String listLimitText)?  $default,) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingListReply() when $default != null:
return $default(_that.items,_that.listLimit,_that.charLimit,_that.listLimitText);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImKeywordBlockingListReply implements CoreImKeywordBlockingListReply {
  const _CoreImKeywordBlockingListReply({final  List<CoreImKeywordBlockingItem> items = const [], this.listLimit = 0, this.charLimit = 0, this.listLimitText = ''}): _items = items;
  

 final  List<CoreImKeywordBlockingItem> _items;
@override@JsonKey() List<CoreImKeywordBlockingItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int listLimit;
@override@JsonKey() final  int charLimit;
@override@JsonKey() final  String listLimitText;

/// Create a copy of CoreImKeywordBlockingListReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImKeywordBlockingListReplyCopyWith<_CoreImKeywordBlockingListReply> get copyWith => __$CoreImKeywordBlockingListReplyCopyWithImpl<_CoreImKeywordBlockingListReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImKeywordBlockingListReply&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.listLimit, listLimit) || other.listLimit == listLimit)&&(identical(other.charLimit, charLimit) || other.charLimit == charLimit)&&(identical(other.listLimitText, listLimitText) || other.listLimitText == listLimitText));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),listLimit,charLimit,listLimitText);

@override
String toString() {
  return 'CoreImKeywordBlockingListReply(items: $items, listLimit: $listLimit, charLimit: $charLimit, listLimitText: $listLimitText)';
}


}

/// @nodoc
abstract mixin class _$CoreImKeywordBlockingListReplyCopyWith<$Res> implements $CoreImKeywordBlockingListReplyCopyWith<$Res> {
  factory _$CoreImKeywordBlockingListReplyCopyWith(_CoreImKeywordBlockingListReply value, $Res Function(_CoreImKeywordBlockingListReply) _then) = __$CoreImKeywordBlockingListReplyCopyWithImpl;
@override @useResult
$Res call({
 List<CoreImKeywordBlockingItem> items, int listLimit, int charLimit, String listLimitText
});




}
/// @nodoc
class __$CoreImKeywordBlockingListReplyCopyWithImpl<$Res>
    implements _$CoreImKeywordBlockingListReplyCopyWith<$Res> {
  __$CoreImKeywordBlockingListReplyCopyWithImpl(this._self, this._then);

  final _CoreImKeywordBlockingListReply _self;
  final $Res Function(_CoreImKeywordBlockingListReply) _then;

/// Create a copy of CoreImKeywordBlockingListReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? listLimit = null,Object? charLimit = null,Object? listLimitText = null,}) {
  return _then(_CoreImKeywordBlockingListReply(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CoreImKeywordBlockingItem>,listLimit: null == listLimit ? _self.listLimit : listLimit // ignore: cast_nullable_to_non_nullable
as int,charLimit: null == charLimit ? _self.charLimit : charLimit // ignore: cast_nullable_to_non_nullable
as int,listLimitText: null == listLimitText ? _self.listLimitText : listLimitText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CoreImKeywordBlockingAddReply {

 String get toast; CoreImKeywordBlockingItem? get item;
/// Create a copy of CoreImKeywordBlockingAddReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImKeywordBlockingAddReplyCopyWith<CoreImKeywordBlockingAddReply> get copyWith => _$CoreImKeywordBlockingAddReplyCopyWithImpl<CoreImKeywordBlockingAddReply>(this as CoreImKeywordBlockingAddReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImKeywordBlockingAddReply&&(identical(other.toast, toast) || other.toast == toast)&&(identical(other.item, item) || other.item == item));
}


@override
int get hashCode => Object.hash(runtimeType,toast,item);

@override
String toString() {
  return 'CoreImKeywordBlockingAddReply(toast: $toast, item: $item)';
}


}

/// @nodoc
abstract mixin class $CoreImKeywordBlockingAddReplyCopyWith<$Res>  {
  factory $CoreImKeywordBlockingAddReplyCopyWith(CoreImKeywordBlockingAddReply value, $Res Function(CoreImKeywordBlockingAddReply) _then) = _$CoreImKeywordBlockingAddReplyCopyWithImpl;
@useResult
$Res call({
 String toast, CoreImKeywordBlockingItem? item
});


$CoreImKeywordBlockingItemCopyWith<$Res>? get item;

}
/// @nodoc
class _$CoreImKeywordBlockingAddReplyCopyWithImpl<$Res>
    implements $CoreImKeywordBlockingAddReplyCopyWith<$Res> {
  _$CoreImKeywordBlockingAddReplyCopyWithImpl(this._self, this._then);

  final CoreImKeywordBlockingAddReply _self;
  final $Res Function(CoreImKeywordBlockingAddReply) _then;

/// Create a copy of CoreImKeywordBlockingAddReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? toast = null,Object? item = freezed,}) {
  return _then(_self.copyWith(
toast: null == toast ? _self.toast : toast // ignore: cast_nullable_to_non_nullable
as String,item: freezed == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as CoreImKeywordBlockingItem?,
  ));
}
/// Create a copy of CoreImKeywordBlockingAddReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreImKeywordBlockingItemCopyWith<$Res>? get item {
    if (_self.item == null) {
    return null;
  }

  return $CoreImKeywordBlockingItemCopyWith<$Res>(_self.item!, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [CoreImKeywordBlockingAddReply].
extension CoreImKeywordBlockingAddReplyPatterns on CoreImKeywordBlockingAddReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImKeywordBlockingAddReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingAddReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImKeywordBlockingAddReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingAddReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImKeywordBlockingAddReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingAddReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String toast,  CoreImKeywordBlockingItem? item)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingAddReply() when $default != null:
return $default(_that.toast,_that.item);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String toast,  CoreImKeywordBlockingItem? item)  $default,) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingAddReply():
return $default(_that.toast,_that.item);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String toast,  CoreImKeywordBlockingItem? item)?  $default,) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingAddReply() when $default != null:
return $default(_that.toast,_that.item);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImKeywordBlockingAddReply implements CoreImKeywordBlockingAddReply {
  const _CoreImKeywordBlockingAddReply({this.toast = '', this.item});
  

@override@JsonKey() final  String toast;
@override final  CoreImKeywordBlockingItem? item;

/// Create a copy of CoreImKeywordBlockingAddReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImKeywordBlockingAddReplyCopyWith<_CoreImKeywordBlockingAddReply> get copyWith => __$CoreImKeywordBlockingAddReplyCopyWithImpl<_CoreImKeywordBlockingAddReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImKeywordBlockingAddReply&&(identical(other.toast, toast) || other.toast == toast)&&(identical(other.item, item) || other.item == item));
}


@override
int get hashCode => Object.hash(runtimeType,toast,item);

@override
String toString() {
  return 'CoreImKeywordBlockingAddReply(toast: $toast, item: $item)';
}


}

/// @nodoc
abstract mixin class _$CoreImKeywordBlockingAddReplyCopyWith<$Res> implements $CoreImKeywordBlockingAddReplyCopyWith<$Res> {
  factory _$CoreImKeywordBlockingAddReplyCopyWith(_CoreImKeywordBlockingAddReply value, $Res Function(_CoreImKeywordBlockingAddReply) _then) = __$CoreImKeywordBlockingAddReplyCopyWithImpl;
@override @useResult
$Res call({
 String toast, CoreImKeywordBlockingItem? item
});


@override $CoreImKeywordBlockingItemCopyWith<$Res>? get item;

}
/// @nodoc
class __$CoreImKeywordBlockingAddReplyCopyWithImpl<$Res>
    implements _$CoreImKeywordBlockingAddReplyCopyWith<$Res> {
  __$CoreImKeywordBlockingAddReplyCopyWithImpl(this._self, this._then);

  final _CoreImKeywordBlockingAddReply _self;
  final $Res Function(_CoreImKeywordBlockingAddReply) _then;

/// Create a copy of CoreImKeywordBlockingAddReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toast = null,Object? item = freezed,}) {
  return _then(_CoreImKeywordBlockingAddReply(
toast: null == toast ? _self.toast : toast // ignore: cast_nullable_to_non_nullable
as String,item: freezed == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as CoreImKeywordBlockingItem?,
  ));
}

/// Create a copy of CoreImKeywordBlockingAddReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreImKeywordBlockingItemCopyWith<$Res>? get item {
    if (_self.item == null) {
    return null;
  }

  return $CoreImKeywordBlockingItemCopyWith<$Res>(_self.item!, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

/// @nodoc
mixin _$CoreImKeywordBlockingDeleteReply {

 String get toast;
/// Create a copy of CoreImKeywordBlockingDeleteReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImKeywordBlockingDeleteReplyCopyWith<CoreImKeywordBlockingDeleteReply> get copyWith => _$CoreImKeywordBlockingDeleteReplyCopyWithImpl<CoreImKeywordBlockingDeleteReply>(this as CoreImKeywordBlockingDeleteReply, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImKeywordBlockingDeleteReply&&(identical(other.toast, toast) || other.toast == toast));
}


@override
int get hashCode => Object.hash(runtimeType,toast);

@override
String toString() {
  return 'CoreImKeywordBlockingDeleteReply(toast: $toast)';
}


}

/// @nodoc
abstract mixin class $CoreImKeywordBlockingDeleteReplyCopyWith<$Res>  {
  factory $CoreImKeywordBlockingDeleteReplyCopyWith(CoreImKeywordBlockingDeleteReply value, $Res Function(CoreImKeywordBlockingDeleteReply) _then) = _$CoreImKeywordBlockingDeleteReplyCopyWithImpl;
@useResult
$Res call({
 String toast
});




}
/// @nodoc
class _$CoreImKeywordBlockingDeleteReplyCopyWithImpl<$Res>
    implements $CoreImKeywordBlockingDeleteReplyCopyWith<$Res> {
  _$CoreImKeywordBlockingDeleteReplyCopyWithImpl(this._self, this._then);

  final CoreImKeywordBlockingDeleteReply _self;
  final $Res Function(CoreImKeywordBlockingDeleteReply) _then;

/// Create a copy of CoreImKeywordBlockingDeleteReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? toast = null,}) {
  return _then(_self.copyWith(
toast: null == toast ? _self.toast : toast // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImKeywordBlockingDeleteReply].
extension CoreImKeywordBlockingDeleteReplyPatterns on CoreImKeywordBlockingDeleteReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImKeywordBlockingDeleteReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingDeleteReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImKeywordBlockingDeleteReply value)  $default,){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingDeleteReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImKeywordBlockingDeleteReply value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImKeywordBlockingDeleteReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String toast)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingDeleteReply() when $default != null:
return $default(_that.toast);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String toast)  $default,) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingDeleteReply():
return $default(_that.toast);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String toast)?  $default,) {final _that = this;
switch (_that) {
case _CoreImKeywordBlockingDeleteReply() when $default != null:
return $default(_that.toast);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImKeywordBlockingDeleteReply implements CoreImKeywordBlockingDeleteReply {
  const _CoreImKeywordBlockingDeleteReply({this.toast = ''});
  

@override@JsonKey() final  String toast;

/// Create a copy of CoreImKeywordBlockingDeleteReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImKeywordBlockingDeleteReplyCopyWith<_CoreImKeywordBlockingDeleteReply> get copyWith => __$CoreImKeywordBlockingDeleteReplyCopyWithImpl<_CoreImKeywordBlockingDeleteReply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImKeywordBlockingDeleteReply&&(identical(other.toast, toast) || other.toast == toast));
}


@override
int get hashCode => Object.hash(runtimeType,toast);

@override
String toString() {
  return 'CoreImKeywordBlockingDeleteReply(toast: $toast)';
}


}

/// @nodoc
abstract mixin class _$CoreImKeywordBlockingDeleteReplyCopyWith<$Res> implements $CoreImKeywordBlockingDeleteReplyCopyWith<$Res> {
  factory _$CoreImKeywordBlockingDeleteReplyCopyWith(_CoreImKeywordBlockingDeleteReply value, $Res Function(_CoreImKeywordBlockingDeleteReply) _then) = __$CoreImKeywordBlockingDeleteReplyCopyWithImpl;
@override @useResult
$Res call({
 String toast
});




}
/// @nodoc
class __$CoreImKeywordBlockingDeleteReplyCopyWithImpl<$Res>
    implements _$CoreImKeywordBlockingDeleteReplyCopyWith<$Res> {
  __$CoreImKeywordBlockingDeleteReplyCopyWithImpl(this._self, this._then);

  final _CoreImKeywordBlockingDeleteReply _self;
  final $Res Function(_CoreImKeywordBlockingDeleteReply) _then;

/// Create a copy of CoreImKeywordBlockingDeleteReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toast = null,}) {
  return _then(_CoreImKeywordBlockingDeleteReply(
toast: null == toast ? _self.toast : toast // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CoreImRspTotalUnread {

 int get totalUnread; Map<String, int>? get msgFeedUnread;
/// Create a copy of CoreImRspTotalUnread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImRspTotalUnreadCopyWith<CoreImRspTotalUnread> get copyWith => _$CoreImRspTotalUnreadCopyWithImpl<CoreImRspTotalUnread>(this as CoreImRspTotalUnread, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImRspTotalUnread&&(identical(other.totalUnread, totalUnread) || other.totalUnread == totalUnread)&&const DeepCollectionEquality().equals(other.msgFeedUnread, msgFeedUnread));
}


@override
int get hashCode => Object.hash(runtimeType,totalUnread,const DeepCollectionEquality().hash(msgFeedUnread));

@override
String toString() {
  return 'CoreImRspTotalUnread(totalUnread: $totalUnread, msgFeedUnread: $msgFeedUnread)';
}


}

/// @nodoc
abstract mixin class $CoreImRspTotalUnreadCopyWith<$Res>  {
  factory $CoreImRspTotalUnreadCopyWith(CoreImRspTotalUnread value, $Res Function(CoreImRspTotalUnread) _then) = _$CoreImRspTotalUnreadCopyWithImpl;
@useResult
$Res call({
 int totalUnread, Map<String, int>? msgFeedUnread
});




}
/// @nodoc
class _$CoreImRspTotalUnreadCopyWithImpl<$Res>
    implements $CoreImRspTotalUnreadCopyWith<$Res> {
  _$CoreImRspTotalUnreadCopyWithImpl(this._self, this._then);

  final CoreImRspTotalUnread _self;
  final $Res Function(CoreImRspTotalUnread) _then;

/// Create a copy of CoreImRspTotalUnread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUnread = null,Object? msgFeedUnread = freezed,}) {
  return _then(_self.copyWith(
totalUnread: null == totalUnread ? _self.totalUnread : totalUnread // ignore: cast_nullable_to_non_nullable
as int,msgFeedUnread: freezed == msgFeedUnread ? _self.msgFeedUnread : msgFeedUnread // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImRspTotalUnread].
extension CoreImRspTotalUnreadPatterns on CoreImRspTotalUnread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImRspTotalUnread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImRspTotalUnread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImRspTotalUnread value)  $default,){
final _that = this;
switch (_that) {
case _CoreImRspTotalUnread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImRspTotalUnread value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImRspTotalUnread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalUnread,  Map<String, int>? msgFeedUnread)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImRspTotalUnread() when $default != null:
return $default(_that.totalUnread,_that.msgFeedUnread);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalUnread,  Map<String, int>? msgFeedUnread)  $default,) {final _that = this;
switch (_that) {
case _CoreImRspTotalUnread():
return $default(_that.totalUnread,_that.msgFeedUnread);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalUnread,  Map<String, int>? msgFeedUnread)?  $default,) {final _that = this;
switch (_that) {
case _CoreImRspTotalUnread() when $default != null:
return $default(_that.totalUnread,_that.msgFeedUnread);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImRspTotalUnread implements CoreImRspTotalUnread {
  const _CoreImRspTotalUnread({this.totalUnread = 0, final  Map<String, int>? msgFeedUnread}): _msgFeedUnread = msgFeedUnread;
  

@override@JsonKey() final  int totalUnread;
 final  Map<String, int>? _msgFeedUnread;
@override Map<String, int>? get msgFeedUnread {
  final value = _msgFeedUnread;
  if (value == null) return null;
  if (_msgFeedUnread is EqualUnmodifiableMapView) return _msgFeedUnread;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CoreImRspTotalUnread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImRspTotalUnreadCopyWith<_CoreImRspTotalUnread> get copyWith => __$CoreImRspTotalUnreadCopyWithImpl<_CoreImRspTotalUnread>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImRspTotalUnread&&(identical(other.totalUnread, totalUnread) || other.totalUnread == totalUnread)&&const DeepCollectionEquality().equals(other._msgFeedUnread, _msgFeedUnread));
}


@override
int get hashCode => Object.hash(runtimeType,totalUnread,const DeepCollectionEquality().hash(_msgFeedUnread));

@override
String toString() {
  return 'CoreImRspTotalUnread(totalUnread: $totalUnread, msgFeedUnread: $msgFeedUnread)';
}


}

/// @nodoc
abstract mixin class _$CoreImRspTotalUnreadCopyWith<$Res> implements $CoreImRspTotalUnreadCopyWith<$Res> {
  factory _$CoreImRspTotalUnreadCopyWith(_CoreImRspTotalUnread value, $Res Function(_CoreImRspTotalUnread) _then) = __$CoreImRspTotalUnreadCopyWithImpl;
@override @useResult
$Res call({
 int totalUnread, Map<String, int>? msgFeedUnread
});




}
/// @nodoc
class __$CoreImRspTotalUnreadCopyWithImpl<$Res>
    implements _$CoreImRspTotalUnreadCopyWith<$Res> {
  __$CoreImRspTotalUnreadCopyWithImpl(this._self, this._then);

  final _CoreImRspTotalUnread _self;
  final $Res Function(_CoreImRspTotalUnread) _then;

/// Create a copy of CoreImRspTotalUnread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUnread = null,Object? msgFeedUnread = freezed,}) {
  return _then(_CoreImRspTotalUnread(
totalUnread: null == totalUnread ? _self.totalUnread : totalUnread // ignore: cast_nullable_to_non_nullable
as int,msgFeedUnread: freezed == msgFeedUnread ? _self._msgFeedUnread : msgFeedUnread // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,
  ));
}


}

/// @nodoc
mixin _$CoreImSessionInfo {

 int get talkerId; int get sessionType; int get unreadCount; String get groupName; String get groupCover; int get ackSeqno; int get atSeqno;
/// Create a copy of CoreImSessionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreImSessionInfoCopyWith<CoreImSessionInfo> get copyWith => _$CoreImSessionInfoCopyWithImpl<CoreImSessionInfo>(this as CoreImSessionInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreImSessionInfo&&(identical(other.talkerId, talkerId) || other.talkerId == talkerId)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupCover, groupCover) || other.groupCover == groupCover)&&(identical(other.ackSeqno, ackSeqno) || other.ackSeqno == ackSeqno)&&(identical(other.atSeqno, atSeqno) || other.atSeqno == atSeqno));
}


@override
int get hashCode => Object.hash(runtimeType,talkerId,sessionType,unreadCount,groupName,groupCover,ackSeqno,atSeqno);

@override
String toString() {
  return 'CoreImSessionInfo(talkerId: $talkerId, sessionType: $sessionType, unreadCount: $unreadCount, groupName: $groupName, groupCover: $groupCover, ackSeqno: $ackSeqno, atSeqno: $atSeqno)';
}


}

/// @nodoc
abstract mixin class $CoreImSessionInfoCopyWith<$Res>  {
  factory $CoreImSessionInfoCopyWith(CoreImSessionInfo value, $Res Function(CoreImSessionInfo) _then) = _$CoreImSessionInfoCopyWithImpl;
@useResult
$Res call({
 int talkerId, int sessionType, int unreadCount, String groupName, String groupCover, int ackSeqno, int atSeqno
});




}
/// @nodoc
class _$CoreImSessionInfoCopyWithImpl<$Res>
    implements $CoreImSessionInfoCopyWith<$Res> {
  _$CoreImSessionInfoCopyWithImpl(this._self, this._then);

  final CoreImSessionInfo _self;
  final $Res Function(CoreImSessionInfo) _then;

/// Create a copy of CoreImSessionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? talkerId = null,Object? sessionType = null,Object? unreadCount = null,Object? groupName = null,Object? groupCover = null,Object? ackSeqno = null,Object? atSeqno = null,}) {
  return _then(_self.copyWith(
talkerId: null == talkerId ? _self.talkerId : talkerId // ignore: cast_nullable_to_non_nullable
as int,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,groupCover: null == groupCover ? _self.groupCover : groupCover // ignore: cast_nullable_to_non_nullable
as String,ackSeqno: null == ackSeqno ? _self.ackSeqno : ackSeqno // ignore: cast_nullable_to_non_nullable
as int,atSeqno: null == atSeqno ? _self.atSeqno : atSeqno // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreImSessionInfo].
extension CoreImSessionInfoPatterns on CoreImSessionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreImSessionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreImSessionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreImSessionInfo value)  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreImSessionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CoreImSessionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int talkerId,  int sessionType,  int unreadCount,  String groupName,  String groupCover,  int ackSeqno,  int atSeqno)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreImSessionInfo() when $default != null:
return $default(_that.talkerId,_that.sessionType,_that.unreadCount,_that.groupName,_that.groupCover,_that.ackSeqno,_that.atSeqno);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int talkerId,  int sessionType,  int unreadCount,  String groupName,  String groupCover,  int ackSeqno,  int atSeqno)  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionInfo():
return $default(_that.talkerId,_that.sessionType,_that.unreadCount,_that.groupName,_that.groupCover,_that.ackSeqno,_that.atSeqno);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int talkerId,  int sessionType,  int unreadCount,  String groupName,  String groupCover,  int ackSeqno,  int atSeqno)?  $default,) {final _that = this;
switch (_that) {
case _CoreImSessionInfo() when $default != null:
return $default(_that.talkerId,_that.sessionType,_that.unreadCount,_that.groupName,_that.groupCover,_that.ackSeqno,_that.atSeqno);case _:
  return null;

}
}

}

/// @nodoc


class _CoreImSessionInfo implements CoreImSessionInfo {
  const _CoreImSessionInfo({this.talkerId = 0, this.sessionType = 0, this.unreadCount = 0, this.groupName = '', this.groupCover = '', this.ackSeqno = 0, this.atSeqno = 0});
  

@override@JsonKey() final  int talkerId;
@override@JsonKey() final  int sessionType;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  String groupName;
@override@JsonKey() final  String groupCover;
@override@JsonKey() final  int ackSeqno;
@override@JsonKey() final  int atSeqno;

/// Create a copy of CoreImSessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreImSessionInfoCopyWith<_CoreImSessionInfo> get copyWith => __$CoreImSessionInfoCopyWithImpl<_CoreImSessionInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreImSessionInfo&&(identical(other.talkerId, talkerId) || other.talkerId == talkerId)&&(identical(other.sessionType, sessionType) || other.sessionType == sessionType)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupCover, groupCover) || other.groupCover == groupCover)&&(identical(other.ackSeqno, ackSeqno) || other.ackSeqno == ackSeqno)&&(identical(other.atSeqno, atSeqno) || other.atSeqno == atSeqno));
}


@override
int get hashCode => Object.hash(runtimeType,talkerId,sessionType,unreadCount,groupName,groupCover,ackSeqno,atSeqno);

@override
String toString() {
  return 'CoreImSessionInfo(talkerId: $talkerId, sessionType: $sessionType, unreadCount: $unreadCount, groupName: $groupName, groupCover: $groupCover, ackSeqno: $ackSeqno, atSeqno: $atSeqno)';
}


}

/// @nodoc
abstract mixin class _$CoreImSessionInfoCopyWith<$Res> implements $CoreImSessionInfoCopyWith<$Res> {
  factory _$CoreImSessionInfoCopyWith(_CoreImSessionInfo value, $Res Function(_CoreImSessionInfo) _then) = __$CoreImSessionInfoCopyWithImpl;
@override @useResult
$Res call({
 int talkerId, int sessionType, int unreadCount, String groupName, String groupCover, int ackSeqno, int atSeqno
});




}
/// @nodoc
class __$CoreImSessionInfoCopyWithImpl<$Res>
    implements _$CoreImSessionInfoCopyWith<$Res> {
  __$CoreImSessionInfoCopyWithImpl(this._self, this._then);

  final _CoreImSessionInfo _self;
  final $Res Function(_CoreImSessionInfo) _then;

/// Create a copy of CoreImSessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? talkerId = null,Object? sessionType = null,Object? unreadCount = null,Object? groupName = null,Object? groupCover = null,Object? ackSeqno = null,Object? atSeqno = null,}) {
  return _then(_CoreImSessionInfo(
talkerId: null == talkerId ? _self.talkerId : talkerId // ignore: cast_nullable_to_non_nullable
as int,sessionType: null == sessionType ? _self.sessionType : sessionType // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,groupCover: null == groupCover ? _self.groupCover : groupCover // ignore: cast_nullable_to_non_nullable
as String,ackSeqno: null == ackSeqno ? _self.ackSeqno : ackSeqno // ignore: cast_nullable_to_non_nullable
as int,atSeqno: null == atSeqno ? _self.atSeqno : atSeqno // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
