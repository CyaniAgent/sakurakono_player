// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoreSourceInfo {

 int get avId; int get cid;
/// Create a copy of CoreSourceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreSourceInfoCopyWith<CoreSourceInfo> get copyWith => _$CoreSourceInfoCopyWithImpl<CoreSourceInfo>(this as CoreSourceInfo, _$identity);

  /// Serializes this CoreSourceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreSourceInfo&&(identical(other.avId, avId) || other.avId == avId)&&(identical(other.cid, cid) || other.cid == cid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,avId,cid);

@override
String toString() {
  return 'CoreSourceInfo(avId: $avId, cid: $cid)';
}


}

/// @nodoc
abstract mixin class $CoreSourceInfoCopyWith<$Res>  {
  factory $CoreSourceInfoCopyWith(CoreSourceInfo value, $Res Function(CoreSourceInfo) _then) = _$CoreSourceInfoCopyWithImpl;
@useResult
$Res call({
 int avId, int cid
});




}
/// @nodoc
class _$CoreSourceInfoCopyWithImpl<$Res>
    implements $CoreSourceInfoCopyWith<$Res> {
  _$CoreSourceInfoCopyWithImpl(this._self, this._then);

  final CoreSourceInfo _self;
  final $Res Function(CoreSourceInfo) _then;

/// Create a copy of CoreSourceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? avId = null,Object? cid = null,}) {
  return _then(_self.copyWith(
avId: null == avId ? _self.avId : avId // ignore: cast_nullable_to_non_nullable
as int,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreSourceInfo].
extension CoreSourceInfoPatterns on CoreSourceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreSourceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreSourceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreSourceInfo value)  $default,){
final _that = this;
switch (_that) {
case _CoreSourceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreSourceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CoreSourceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int avId,  int cid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreSourceInfo() when $default != null:
return $default(_that.avId,_that.cid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int avId,  int cid)  $default,) {final _that = this;
switch (_that) {
case _CoreSourceInfo():
return $default(_that.avId,_that.cid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int avId,  int cid)?  $default,) {final _that = this;
switch (_that) {
case _CoreSourceInfo() when $default != null:
return $default(_that.avId,_that.cid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreSourceInfo implements CoreSourceInfo {
  const _CoreSourceInfo({required this.avId, required this.cid});
  factory _CoreSourceInfo.fromJson(Map<String, dynamic> json) => _$CoreSourceInfoFromJson(json);

@override final  int avId;
@override final  int cid;

/// Create a copy of CoreSourceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreSourceInfoCopyWith<_CoreSourceInfo> get copyWith => __$CoreSourceInfoCopyWithImpl<_CoreSourceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreSourceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreSourceInfo&&(identical(other.avId, avId) || other.avId == avId)&&(identical(other.cid, cid) || other.cid == cid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,avId,cid);

@override
String toString() {
  return 'CoreSourceInfo(avId: $avId, cid: $cid)';
}


}

/// @nodoc
abstract mixin class _$CoreSourceInfoCopyWith<$Res> implements $CoreSourceInfoCopyWith<$Res> {
  factory _$CoreSourceInfoCopyWith(_CoreSourceInfo value, $Res Function(_CoreSourceInfo) _then) = __$CoreSourceInfoCopyWithImpl;
@override @useResult
$Res call({
 int avId, int cid
});




}
/// @nodoc
class __$CoreSourceInfoCopyWithImpl<$Res>
    implements _$CoreSourceInfoCopyWith<$Res> {
  __$CoreSourceInfoCopyWithImpl(this._self, this._then);

  final _CoreSourceInfo _self;
  final $Res Function(_CoreSourceInfo) _then;

/// Create a copy of CoreSourceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? avId = null,Object? cid = null,}) {
  return _then(_CoreSourceInfo(
avId: null == avId ? _self.avId : avId // ignore: cast_nullable_to_non_nullable
as int,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CoreType1PlayerCodecConfig {

 String get player; bool get useIjkMediaCodec;
/// Create a copy of CoreType1PlayerCodecConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreType1PlayerCodecConfigCopyWith<CoreType1PlayerCodecConfig> get copyWith => _$CoreType1PlayerCodecConfigCopyWithImpl<CoreType1PlayerCodecConfig>(this as CoreType1PlayerCodecConfig, _$identity);

  /// Serializes this CoreType1PlayerCodecConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreType1PlayerCodecConfig&&(identical(other.player, player) || other.player == player)&&(identical(other.useIjkMediaCodec, useIjkMediaCodec) || other.useIjkMediaCodec == useIjkMediaCodec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,player,useIjkMediaCodec);

@override
String toString() {
  return 'CoreType1PlayerCodecConfig(player: $player, useIjkMediaCodec: $useIjkMediaCodec)';
}


}

/// @nodoc
abstract mixin class $CoreType1PlayerCodecConfigCopyWith<$Res>  {
  factory $CoreType1PlayerCodecConfigCopyWith(CoreType1PlayerCodecConfig value, $Res Function(CoreType1PlayerCodecConfig) _then) = _$CoreType1PlayerCodecConfigCopyWithImpl;
@useResult
$Res call({
 String player, bool useIjkMediaCodec
});




}
/// @nodoc
class _$CoreType1PlayerCodecConfigCopyWithImpl<$Res>
    implements $CoreType1PlayerCodecConfigCopyWith<$Res> {
  _$CoreType1PlayerCodecConfigCopyWithImpl(this._self, this._then);

  final CoreType1PlayerCodecConfig _self;
  final $Res Function(CoreType1PlayerCodecConfig) _then;

/// Create a copy of CoreType1PlayerCodecConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? player = null,Object? useIjkMediaCodec = null,}) {
  return _then(_self.copyWith(
player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as String,useIjkMediaCodec: null == useIjkMediaCodec ? _self.useIjkMediaCodec : useIjkMediaCodec // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreType1PlayerCodecConfig].
extension CoreType1PlayerCodecConfigPatterns on CoreType1PlayerCodecConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreType1PlayerCodecConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreType1PlayerCodecConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreType1PlayerCodecConfig value)  $default,){
final _that = this;
switch (_that) {
case _CoreType1PlayerCodecConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreType1PlayerCodecConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CoreType1PlayerCodecConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String player,  bool useIjkMediaCodec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreType1PlayerCodecConfig() when $default != null:
return $default(_that.player,_that.useIjkMediaCodec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String player,  bool useIjkMediaCodec)  $default,) {final _that = this;
switch (_that) {
case _CoreType1PlayerCodecConfig():
return $default(_that.player,_that.useIjkMediaCodec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String player,  bool useIjkMediaCodec)?  $default,) {final _that = this;
switch (_that) {
case _CoreType1PlayerCodecConfig() when $default != null:
return $default(_that.player,_that.useIjkMediaCodec);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreType1PlayerCodecConfig implements CoreType1PlayerCodecConfig {
  const _CoreType1PlayerCodecConfig({required this.player, required this.useIjkMediaCodec});
  factory _CoreType1PlayerCodecConfig.fromJson(Map<String, dynamic> json) => _$CoreType1PlayerCodecConfigFromJson(json);

@override final  String player;
@override final  bool useIjkMediaCodec;

/// Create a copy of CoreType1PlayerCodecConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreType1PlayerCodecConfigCopyWith<_CoreType1PlayerCodecConfig> get copyWith => __$CoreType1PlayerCodecConfigCopyWithImpl<_CoreType1PlayerCodecConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreType1PlayerCodecConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreType1PlayerCodecConfig&&(identical(other.player, player) || other.player == player)&&(identical(other.useIjkMediaCodec, useIjkMediaCodec) || other.useIjkMediaCodec == useIjkMediaCodec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,player,useIjkMediaCodec);

@override
String toString() {
  return 'CoreType1PlayerCodecConfig(player: $player, useIjkMediaCodec: $useIjkMediaCodec)';
}


}

/// @nodoc
abstract mixin class _$CoreType1PlayerCodecConfigCopyWith<$Res> implements $CoreType1PlayerCodecConfigCopyWith<$Res> {
  factory _$CoreType1PlayerCodecConfigCopyWith(_CoreType1PlayerCodecConfig value, $Res Function(_CoreType1PlayerCodecConfig) _then) = __$CoreType1PlayerCodecConfigCopyWithImpl;
@override @useResult
$Res call({
 String player, bool useIjkMediaCodec
});




}
/// @nodoc
class __$CoreType1PlayerCodecConfigCopyWithImpl<$Res>
    implements _$CoreType1PlayerCodecConfigCopyWith<$Res> {
  __$CoreType1PlayerCodecConfigCopyWithImpl(this._self, this._then);

  final _CoreType1PlayerCodecConfig _self;
  final $Res Function(_CoreType1PlayerCodecConfig) _then;

/// Create a copy of CoreType1PlayerCodecConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? player = null,Object? useIjkMediaCodec = null,}) {
  return _then(_CoreType1PlayerCodecConfig(
player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as String,useIjkMediaCodec: null == useIjkMediaCodec ? _self.useIjkMediaCodec : useIjkMediaCodec // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CoreType1Segment {

 List<String> get backupUrls; int get bytes; int get duration; String get md5; String get metaUrl; int get order; String get url;
/// Create a copy of CoreType1Segment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreType1SegmentCopyWith<CoreType1Segment> get copyWith => _$CoreType1SegmentCopyWithImpl<CoreType1Segment>(this as CoreType1Segment, _$identity);

  /// Serializes this CoreType1Segment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreType1Segment&&const DeepCollectionEquality().equals(other.backupUrls, backupUrls)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.md5, md5) || other.md5 == md5)&&(identical(other.metaUrl, metaUrl) || other.metaUrl == metaUrl)&&(identical(other.order, order) || other.order == order)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(backupUrls),bytes,duration,md5,metaUrl,order,url);

@override
String toString() {
  return 'CoreType1Segment(backupUrls: $backupUrls, bytes: $bytes, duration: $duration, md5: $md5, metaUrl: $metaUrl, order: $order, url: $url)';
}


}

/// @nodoc
abstract mixin class $CoreType1SegmentCopyWith<$Res>  {
  factory $CoreType1SegmentCopyWith(CoreType1Segment value, $Res Function(CoreType1Segment) _then) = _$CoreType1SegmentCopyWithImpl;
@useResult
$Res call({
 List<String> backupUrls, int bytes, int duration, String md5, String metaUrl, int order, String url
});




}
/// @nodoc
class _$CoreType1SegmentCopyWithImpl<$Res>
    implements $CoreType1SegmentCopyWith<$Res> {
  _$CoreType1SegmentCopyWithImpl(this._self, this._then);

  final CoreType1Segment _self;
  final $Res Function(CoreType1Segment) _then;

/// Create a copy of CoreType1Segment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? backupUrls = null,Object? bytes = null,Object? duration = null,Object? md5 = null,Object? metaUrl = null,Object? order = null,Object? url = null,}) {
  return _then(_self.copyWith(
backupUrls: null == backupUrls ? _self.backupUrls : backupUrls // ignore: cast_nullable_to_non_nullable
as List<String>,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,md5: null == md5 ? _self.md5 : md5 // ignore: cast_nullable_to_non_nullable
as String,metaUrl: null == metaUrl ? _self.metaUrl : metaUrl // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreType1Segment].
extension CoreType1SegmentPatterns on CoreType1Segment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreType1Segment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreType1Segment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreType1Segment value)  $default,){
final _that = this;
switch (_that) {
case _CoreType1Segment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreType1Segment value)?  $default,){
final _that = this;
switch (_that) {
case _CoreType1Segment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> backupUrls,  int bytes,  int duration,  String md5,  String metaUrl,  int order,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreType1Segment() when $default != null:
return $default(_that.backupUrls,_that.bytes,_that.duration,_that.md5,_that.metaUrl,_that.order,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> backupUrls,  int bytes,  int duration,  String md5,  String metaUrl,  int order,  String url)  $default,) {final _that = this;
switch (_that) {
case _CoreType1Segment():
return $default(_that.backupUrls,_that.bytes,_that.duration,_that.md5,_that.metaUrl,_that.order,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> backupUrls,  int bytes,  int duration,  String md5,  String metaUrl,  int order,  String url)?  $default,) {final _that = this;
switch (_that) {
case _CoreType1Segment() when $default != null:
return $default(_that.backupUrls,_that.bytes,_that.duration,_that.md5,_that.metaUrl,_that.order,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreType1Segment implements CoreType1Segment {
  const _CoreType1Segment({required final  List<String> backupUrls, required this.bytes, this.duration = 0, required this.md5, required this.metaUrl, required this.order, required this.url}): _backupUrls = backupUrls;
  factory _CoreType1Segment.fromJson(Map<String, dynamic> json) => _$CoreType1SegmentFromJson(json);

 final  List<String> _backupUrls;
@override List<String> get backupUrls {
  if (_backupUrls is EqualUnmodifiableListView) return _backupUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_backupUrls);
}

@override final  int bytes;
@override@JsonKey() final  int duration;
@override final  String md5;
@override final  String metaUrl;
@override final  int order;
@override final  String url;

/// Create a copy of CoreType1Segment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreType1SegmentCopyWith<_CoreType1Segment> get copyWith => __$CoreType1SegmentCopyWithImpl<_CoreType1Segment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreType1SegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreType1Segment&&const DeepCollectionEquality().equals(other._backupUrls, _backupUrls)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.md5, md5) || other.md5 == md5)&&(identical(other.metaUrl, metaUrl) || other.metaUrl == metaUrl)&&(identical(other.order, order) || other.order == order)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_backupUrls),bytes,duration,md5,metaUrl,order,url);

@override
String toString() {
  return 'CoreType1Segment(backupUrls: $backupUrls, bytes: $bytes, duration: $duration, md5: $md5, metaUrl: $metaUrl, order: $order, url: $url)';
}


}

/// @nodoc
abstract mixin class _$CoreType1SegmentCopyWith<$Res> implements $CoreType1SegmentCopyWith<$Res> {
  factory _$CoreType1SegmentCopyWith(_CoreType1Segment value, $Res Function(_CoreType1Segment) _then) = __$CoreType1SegmentCopyWithImpl;
@override @useResult
$Res call({
 List<String> backupUrls, int bytes, int duration, String md5, String metaUrl, int order, String url
});




}
/// @nodoc
class __$CoreType1SegmentCopyWithImpl<$Res>
    implements _$CoreType1SegmentCopyWith<$Res> {
  __$CoreType1SegmentCopyWithImpl(this._self, this._then);

  final _CoreType1Segment _self;
  final $Res Function(_CoreType1Segment) _then;

/// Create a copy of CoreType1Segment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backupUrls = null,Object? bytes = null,Object? duration = null,Object? md5 = null,Object? metaUrl = null,Object? order = null,Object? url = null,}) {
  return _then(_CoreType1Segment(
backupUrls: null == backupUrls ? _self._backupUrls : backupUrls // ignore: cast_nullable_to_non_nullable
as List<String>,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,md5: null == md5 ? _self.md5 : md5 // ignore: cast_nullable_to_non_nullable
as String,metaUrl: null == metaUrl ? _self.metaUrl : metaUrl // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
