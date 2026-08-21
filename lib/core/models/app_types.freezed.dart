// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreUpdateInfo {

 bool get hasUpdate; String? get latestVersion; String? get downloadUrl; String? get releaseNotes; String? get publishedAt;
/// Create a copy of CoreUpdateInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreUpdateInfoCopyWith<CoreUpdateInfo> get copyWith => _$CoreUpdateInfoCopyWithImpl<CoreUpdateInfo>(this as CoreUpdateInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreUpdateInfo&&(identical(other.hasUpdate, hasUpdate) || other.hasUpdate == hasUpdate)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,hasUpdate,latestVersion,downloadUrl,releaseNotes,publishedAt);

@override
String toString() {
  return 'CoreUpdateInfo(hasUpdate: $hasUpdate, latestVersion: $latestVersion, downloadUrl: $downloadUrl, releaseNotes: $releaseNotes, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $CoreUpdateInfoCopyWith<$Res>  {
  factory $CoreUpdateInfoCopyWith(CoreUpdateInfo value, $Res Function(CoreUpdateInfo) _then) = _$CoreUpdateInfoCopyWithImpl;
@useResult
$Res call({
 bool hasUpdate, String? latestVersion, String? downloadUrl, String? releaseNotes, String? publishedAt
});




}
/// @nodoc
class _$CoreUpdateInfoCopyWithImpl<$Res>
    implements $CoreUpdateInfoCopyWith<$Res> {
  _$CoreUpdateInfoCopyWithImpl(this._self, this._then);

  final CoreUpdateInfo _self;
  final $Res Function(CoreUpdateInfo) _then;

/// Create a copy of CoreUpdateInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasUpdate = null,Object? latestVersion = freezed,Object? downloadUrl = freezed,Object? releaseNotes = freezed,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
hasUpdate: null == hasUpdate ? _self.hasUpdate : hasUpdate // ignore: cast_nullable_to_non_nullable
as bool,latestVersion: freezed == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,releaseNotes: freezed == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreUpdateInfo].
extension CoreUpdateInfoPatterns on CoreUpdateInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreUpdateInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreUpdateInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreUpdateInfo value)  $default,){
final _that = this;
switch (_that) {
case _CoreUpdateInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreUpdateInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CoreUpdateInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasUpdate,  String? latestVersion,  String? downloadUrl,  String? releaseNotes,  String? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreUpdateInfo() when $default != null:
return $default(_that.hasUpdate,_that.latestVersion,_that.downloadUrl,_that.releaseNotes,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasUpdate,  String? latestVersion,  String? downloadUrl,  String? releaseNotes,  String? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _CoreUpdateInfo():
return $default(_that.hasUpdate,_that.latestVersion,_that.downloadUrl,_that.releaseNotes,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasUpdate,  String? latestVersion,  String? downloadUrl,  String? releaseNotes,  String? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _CoreUpdateInfo() when $default != null:
return $default(_that.hasUpdate,_that.latestVersion,_that.downloadUrl,_that.releaseNotes,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CoreUpdateInfo implements CoreUpdateInfo {
  const _CoreUpdateInfo({this.hasUpdate = false, this.latestVersion, this.downloadUrl, this.releaseNotes, this.publishedAt});
  

@override@JsonKey() final  bool hasUpdate;
@override final  String? latestVersion;
@override final  String? downloadUrl;
@override final  String? releaseNotes;
@override final  String? publishedAt;

/// Create a copy of CoreUpdateInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreUpdateInfoCopyWith<_CoreUpdateInfo> get copyWith => __$CoreUpdateInfoCopyWithImpl<_CoreUpdateInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreUpdateInfo&&(identical(other.hasUpdate, hasUpdate) || other.hasUpdate == hasUpdate)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,hasUpdate,latestVersion,downloadUrl,releaseNotes,publishedAt);

@override
String toString() {
  return 'CoreUpdateInfo(hasUpdate: $hasUpdate, latestVersion: $latestVersion, downloadUrl: $downloadUrl, releaseNotes: $releaseNotes, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$CoreUpdateInfoCopyWith<$Res> implements $CoreUpdateInfoCopyWith<$Res> {
  factory _$CoreUpdateInfoCopyWith(_CoreUpdateInfo value, $Res Function(_CoreUpdateInfo) _then) = __$CoreUpdateInfoCopyWithImpl;
@override @useResult
$Res call({
 bool hasUpdate, String? latestVersion, String? downloadUrl, String? releaseNotes, String? publishedAt
});




}
/// @nodoc
class __$CoreUpdateInfoCopyWithImpl<$Res>
    implements _$CoreUpdateInfoCopyWith<$Res> {
  __$CoreUpdateInfoCopyWithImpl(this._self, this._then);

  final _CoreUpdateInfo _self;
  final $Res Function(_CoreUpdateInfo) _then;

/// Create a copy of CoreUpdateInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasUpdate = null,Object? latestVersion = freezed,Object? downloadUrl = freezed,Object? releaseNotes = freezed,Object? publishedAt = freezed,}) {
  return _then(_CoreUpdateInfo(
hasUpdate: null == hasUpdate ? _self.hasUpdate : hasUpdate // ignore: cast_nullable_to_non_nullable
as bool,latestVersion: freezed == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,releaseNotes: freezed == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
