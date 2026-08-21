// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreLoginDevicesData {

 List<CoreLoginDevice>? get devices;
/// Create a copy of CoreLoginDevicesData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreLoginDevicesDataCopyWith<CoreLoginDevicesData> get copyWith => _$CoreLoginDevicesDataCopyWithImpl<CoreLoginDevicesData>(this as CoreLoginDevicesData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreLoginDevicesData&&const DeepCollectionEquality().equals(other.devices, devices));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(devices));

@override
String toString() {
  return 'CoreLoginDevicesData(devices: $devices)';
}


}

/// @nodoc
abstract mixin class $CoreLoginDevicesDataCopyWith<$Res>  {
  factory $CoreLoginDevicesDataCopyWith(CoreLoginDevicesData value, $Res Function(CoreLoginDevicesData) _then) = _$CoreLoginDevicesDataCopyWithImpl;
@useResult
$Res call({
 List<CoreLoginDevice>? devices
});




}
/// @nodoc
class _$CoreLoginDevicesDataCopyWithImpl<$Res>
    implements $CoreLoginDevicesDataCopyWith<$Res> {
  _$CoreLoginDevicesDataCopyWithImpl(this._self, this._then);

  final CoreLoginDevicesData _self;
  final $Res Function(CoreLoginDevicesData) _then;

/// Create a copy of CoreLoginDevicesData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? devices = freezed,}) {
  return _then(_self.copyWith(
devices: freezed == devices ? _self.devices : devices // ignore: cast_nullable_to_non_nullable
as List<CoreLoginDevice>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreLoginDevicesData].
extension CoreLoginDevicesDataPatterns on CoreLoginDevicesData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreLoginDevicesData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreLoginDevicesData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreLoginDevicesData value)  $default,){
final _that = this;
switch (_that) {
case _CoreLoginDevicesData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreLoginDevicesData value)?  $default,){
final _that = this;
switch (_that) {
case _CoreLoginDevicesData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CoreLoginDevice>? devices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreLoginDevicesData() when $default != null:
return $default(_that.devices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CoreLoginDevice>? devices)  $default,) {final _that = this;
switch (_that) {
case _CoreLoginDevicesData():
return $default(_that.devices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CoreLoginDevice>? devices)?  $default,) {final _that = this;
switch (_that) {
case _CoreLoginDevicesData() when $default != null:
return $default(_that.devices);case _:
  return null;

}
}

}

/// @nodoc


class _CoreLoginDevicesData implements CoreLoginDevicesData {
  const _CoreLoginDevicesData({final  List<CoreLoginDevice>? devices}): _devices = devices;
  

 final  List<CoreLoginDevice>? _devices;
@override List<CoreLoginDevice>? get devices {
  final value = _devices;
  if (value == null) return null;
  if (_devices is EqualUnmodifiableListView) return _devices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CoreLoginDevicesData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreLoginDevicesDataCopyWith<_CoreLoginDevicesData> get copyWith => __$CoreLoginDevicesDataCopyWithImpl<_CoreLoginDevicesData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreLoginDevicesData&&const DeepCollectionEquality().equals(other._devices, _devices));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_devices));

@override
String toString() {
  return 'CoreLoginDevicesData(devices: $devices)';
}


}

/// @nodoc
abstract mixin class _$CoreLoginDevicesDataCopyWith<$Res> implements $CoreLoginDevicesDataCopyWith<$Res> {
  factory _$CoreLoginDevicesDataCopyWith(_CoreLoginDevicesData value, $Res Function(_CoreLoginDevicesData) _then) = __$CoreLoginDevicesDataCopyWithImpl;
@override @useResult
$Res call({
 List<CoreLoginDevice>? devices
});




}
/// @nodoc
class __$CoreLoginDevicesDataCopyWithImpl<$Res>
    implements _$CoreLoginDevicesDataCopyWith<$Res> {
  __$CoreLoginDevicesDataCopyWithImpl(this._self, this._then);

  final _CoreLoginDevicesData _self;
  final $Res Function(_CoreLoginDevicesData) _then;

/// Create a copy of CoreLoginDevicesData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? devices = freezed,}) {
  return _then(_CoreLoginDevicesData(
devices: freezed == devices ? _self._devices : devices // ignore: cast_nullable_to_non_nullable
as List<CoreLoginDevice>?,
  ));
}


}

/// @nodoc
mixin _$CoreLoginDevice {

 String? get deviceName; bool? get isCurrentDevice; String? get latestLoginAt; String? get source;
/// Create a copy of CoreLoginDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreLoginDeviceCopyWith<CoreLoginDevice> get copyWith => _$CoreLoginDeviceCopyWithImpl<CoreLoginDevice>(this as CoreLoginDevice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreLoginDevice&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.isCurrentDevice, isCurrentDevice) || other.isCurrentDevice == isCurrentDevice)&&(identical(other.latestLoginAt, latestLoginAt) || other.latestLoginAt == latestLoginAt)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,deviceName,isCurrentDevice,latestLoginAt,source);

@override
String toString() {
  return 'CoreLoginDevice(deviceName: $deviceName, isCurrentDevice: $isCurrentDevice, latestLoginAt: $latestLoginAt, source: $source)';
}


}

/// @nodoc
abstract mixin class $CoreLoginDeviceCopyWith<$Res>  {
  factory $CoreLoginDeviceCopyWith(CoreLoginDevice value, $Res Function(CoreLoginDevice) _then) = _$CoreLoginDeviceCopyWithImpl;
@useResult
$Res call({
 String? deviceName, bool? isCurrentDevice, String? latestLoginAt, String? source
});




}
/// @nodoc
class _$CoreLoginDeviceCopyWithImpl<$Res>
    implements $CoreLoginDeviceCopyWith<$Res> {
  _$CoreLoginDeviceCopyWithImpl(this._self, this._then);

  final CoreLoginDevice _self;
  final $Res Function(CoreLoginDevice) _then;

/// Create a copy of CoreLoginDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceName = freezed,Object? isCurrentDevice = freezed,Object? latestLoginAt = freezed,Object? source = freezed,}) {
  return _then(_self.copyWith(
deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,isCurrentDevice: freezed == isCurrentDevice ? _self.isCurrentDevice : isCurrentDevice // ignore: cast_nullable_to_non_nullable
as bool?,latestLoginAt: freezed == latestLoginAt ? _self.latestLoginAt : latestLoginAt // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreLoginDevice].
extension CoreLoginDevicePatterns on CoreLoginDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreLoginDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreLoginDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreLoginDevice value)  $default,){
final _that = this;
switch (_that) {
case _CoreLoginDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreLoginDevice value)?  $default,){
final _that = this;
switch (_that) {
case _CoreLoginDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? deviceName,  bool? isCurrentDevice,  String? latestLoginAt,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreLoginDevice() when $default != null:
return $default(_that.deviceName,_that.isCurrentDevice,_that.latestLoginAt,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? deviceName,  bool? isCurrentDevice,  String? latestLoginAt,  String? source)  $default,) {final _that = this;
switch (_that) {
case _CoreLoginDevice():
return $default(_that.deviceName,_that.isCurrentDevice,_that.latestLoginAt,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? deviceName,  bool? isCurrentDevice,  String? latestLoginAt,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _CoreLoginDevice() when $default != null:
return $default(_that.deviceName,_that.isCurrentDevice,_that.latestLoginAt,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _CoreLoginDevice implements CoreLoginDevice {
  const _CoreLoginDevice({this.deviceName, this.isCurrentDevice, this.latestLoginAt, this.source});
  

@override final  String? deviceName;
@override final  bool? isCurrentDevice;
@override final  String? latestLoginAt;
@override final  String? source;

/// Create a copy of CoreLoginDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreLoginDeviceCopyWith<_CoreLoginDevice> get copyWith => __$CoreLoginDeviceCopyWithImpl<_CoreLoginDevice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreLoginDevice&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.isCurrentDevice, isCurrentDevice) || other.isCurrentDevice == isCurrentDevice)&&(identical(other.latestLoginAt, latestLoginAt) || other.latestLoginAt == latestLoginAt)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,deviceName,isCurrentDevice,latestLoginAt,source);

@override
String toString() {
  return 'CoreLoginDevice(deviceName: $deviceName, isCurrentDevice: $isCurrentDevice, latestLoginAt: $latestLoginAt, source: $source)';
}


}

/// @nodoc
abstract mixin class _$CoreLoginDeviceCopyWith<$Res> implements $CoreLoginDeviceCopyWith<$Res> {
  factory _$CoreLoginDeviceCopyWith(_CoreLoginDevice value, $Res Function(_CoreLoginDevice) _then) = __$CoreLoginDeviceCopyWithImpl;
@override @useResult
$Res call({
 String? deviceName, bool? isCurrentDevice, String? latestLoginAt, String? source
});




}
/// @nodoc
class __$CoreLoginDeviceCopyWithImpl<$Res>
    implements _$CoreLoginDeviceCopyWith<$Res> {
  __$CoreLoginDeviceCopyWithImpl(this._self, this._then);

  final _CoreLoginDevice _self;
  final $Res Function(_CoreLoginDevice) _then;

/// Create a copy of CoreLoginDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceName = freezed,Object? isCurrentDevice = freezed,Object? latestLoginAt = freezed,Object? source = freezed,}) {
  return _then(_CoreLoginDevice(
deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,isCurrentDevice: freezed == isCurrentDevice ? _self.isCurrentDevice : isCurrentDevice // ignore: cast_nullable_to_non_nullable
as bool?,latestLoginAt: freezed == latestLoginAt ? _self.latestLoginAt : latestLoginAt // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CoreAccount {

 bool get isLogin; int get mid; String? get accessKey; bool get activated;
/// Create a copy of CoreAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreAccountCopyWith<CoreAccount> get copyWith => _$CoreAccountCopyWithImpl<CoreAccount>(this as CoreAccount, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreAccount&&(identical(other.isLogin, isLogin) || other.isLogin == isLogin)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.accessKey, accessKey) || other.accessKey == accessKey)&&(identical(other.activated, activated) || other.activated == activated));
}


@override
int get hashCode => Object.hash(runtimeType,isLogin,mid,accessKey,activated);

@override
String toString() {
  return 'CoreAccount(isLogin: $isLogin, mid: $mid, accessKey: $accessKey, activated: $activated)';
}


}

/// @nodoc
abstract mixin class $CoreAccountCopyWith<$Res>  {
  factory $CoreAccountCopyWith(CoreAccount value, $Res Function(CoreAccount) _then) = _$CoreAccountCopyWithImpl;
@useResult
$Res call({
 bool isLogin, int mid, String? accessKey, bool activated
});




}
/// @nodoc
class _$CoreAccountCopyWithImpl<$Res>
    implements $CoreAccountCopyWith<$Res> {
  _$CoreAccountCopyWithImpl(this._self, this._then);

  final CoreAccount _self;
  final $Res Function(CoreAccount) _then;

/// Create a copy of CoreAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLogin = null,Object? mid = null,Object? accessKey = freezed,Object? activated = null,}) {
  return _then(_self.copyWith(
isLogin: null == isLogin ? _self.isLogin : isLogin // ignore: cast_nullable_to_non_nullable
as bool,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,accessKey: freezed == accessKey ? _self.accessKey : accessKey // ignore: cast_nullable_to_non_nullable
as String?,activated: null == activated ? _self.activated : activated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreAccount].
extension CoreAccountPatterns on CoreAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreAccount value)  $default,){
final _that = this;
switch (_that) {
case _CoreAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreAccount value)?  $default,){
final _that = this;
switch (_that) {
case _CoreAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLogin,  int mid,  String? accessKey,  bool activated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreAccount() when $default != null:
return $default(_that.isLogin,_that.mid,_that.accessKey,_that.activated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLogin,  int mid,  String? accessKey,  bool activated)  $default,) {final _that = this;
switch (_that) {
case _CoreAccount():
return $default(_that.isLogin,_that.mid,_that.accessKey,_that.activated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLogin,  int mid,  String? accessKey,  bool activated)?  $default,) {final _that = this;
switch (_that) {
case _CoreAccount() when $default != null:
return $default(_that.isLogin,_that.mid,_that.accessKey,_that.activated);case _:
  return null;

}
}

}

/// @nodoc


class _CoreAccount implements CoreAccount {
  const _CoreAccount({this.isLogin = false, this.mid = 0, this.accessKey, this.activated = false});
  

@override@JsonKey() final  bool isLogin;
@override@JsonKey() final  int mid;
@override final  String? accessKey;
@override@JsonKey() final  bool activated;

/// Create a copy of CoreAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreAccountCopyWith<_CoreAccount> get copyWith => __$CoreAccountCopyWithImpl<_CoreAccount>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreAccount&&(identical(other.isLogin, isLogin) || other.isLogin == isLogin)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.accessKey, accessKey) || other.accessKey == accessKey)&&(identical(other.activated, activated) || other.activated == activated));
}


@override
int get hashCode => Object.hash(runtimeType,isLogin,mid,accessKey,activated);

@override
String toString() {
  return 'CoreAccount(isLogin: $isLogin, mid: $mid, accessKey: $accessKey, activated: $activated)';
}


}

/// @nodoc
abstract mixin class _$CoreAccountCopyWith<$Res> implements $CoreAccountCopyWith<$Res> {
  factory _$CoreAccountCopyWith(_CoreAccount value, $Res Function(_CoreAccount) _then) = __$CoreAccountCopyWithImpl;
@override @useResult
$Res call({
 bool isLogin, int mid, String? accessKey, bool activated
});




}
/// @nodoc
class __$CoreAccountCopyWithImpl<$Res>
    implements _$CoreAccountCopyWith<$Res> {
  __$CoreAccountCopyWithImpl(this._self, this._then);

  final _CoreAccount _self;
  final $Res Function(_CoreAccount) _then;

/// Create a copy of CoreAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLogin = null,Object? mid = null,Object? accessKey = freezed,Object? activated = null,}) {
  return _then(_CoreAccount(
isLogin: null == isLogin ? _self.isLogin : isLogin // ignore: cast_nullable_to_non_nullable
as bool,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,accessKey: freezed == accessKey ? _self.accessKey : accessKey // ignore: cast_nullable_to_non_nullable
as String?,activated: null == activated ? _self.activated : activated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CoreLoginResult {

 bool get success; String? get message; CoreAccount? get account;
/// Create a copy of CoreLoginResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreLoginResultCopyWith<CoreLoginResult> get copyWith => _$CoreLoginResultCopyWithImpl<CoreLoginResult>(this as CoreLoginResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreLoginResult&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.account, account) || other.account == account));
}


@override
int get hashCode => Object.hash(runtimeType,success,message,account);

@override
String toString() {
  return 'CoreLoginResult(success: $success, message: $message, account: $account)';
}


}

/// @nodoc
abstract mixin class $CoreLoginResultCopyWith<$Res>  {
  factory $CoreLoginResultCopyWith(CoreLoginResult value, $Res Function(CoreLoginResult) _then) = _$CoreLoginResultCopyWithImpl;
@useResult
$Res call({
 bool success, String? message, CoreAccount? account
});


$CoreAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$CoreLoginResultCopyWithImpl<$Res>
    implements $CoreLoginResultCopyWith<$Res> {
  _$CoreLoginResultCopyWithImpl(this._self, this._then);

  final CoreLoginResult _self;
  final $Res Function(CoreLoginResult) _then;

/// Create a copy of CoreLoginResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = freezed,Object? account = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as CoreAccount?,
  ));
}
/// Create a copy of CoreLoginResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $CoreAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [CoreLoginResult].
extension CoreLoginResultPatterns on CoreLoginResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreLoginResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreLoginResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreLoginResult value)  $default,){
final _that = this;
switch (_that) {
case _CoreLoginResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreLoginResult value)?  $default,){
final _that = this;
switch (_that) {
case _CoreLoginResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String? message,  CoreAccount? account)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreLoginResult() when $default != null:
return $default(_that.success,_that.message,_that.account);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String? message,  CoreAccount? account)  $default,) {final _that = this;
switch (_that) {
case _CoreLoginResult():
return $default(_that.success,_that.message,_that.account);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String? message,  CoreAccount? account)?  $default,) {final _that = this;
switch (_that) {
case _CoreLoginResult() when $default != null:
return $default(_that.success,_that.message,_that.account);case _:
  return null;

}
}

}

/// @nodoc


class _CoreLoginResult implements CoreLoginResult {
  const _CoreLoginResult({required this.success, this.message, this.account});
  

@override final  bool success;
@override final  String? message;
@override final  CoreAccount? account;

/// Create a copy of CoreLoginResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreLoginResultCopyWith<_CoreLoginResult> get copyWith => __$CoreLoginResultCopyWithImpl<_CoreLoginResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreLoginResult&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.account, account) || other.account == account));
}


@override
int get hashCode => Object.hash(runtimeType,success,message,account);

@override
String toString() {
  return 'CoreLoginResult(success: $success, message: $message, account: $account)';
}


}

/// @nodoc
abstract mixin class _$CoreLoginResultCopyWith<$Res> implements $CoreLoginResultCopyWith<$Res> {
  factory _$CoreLoginResultCopyWith(_CoreLoginResult value, $Res Function(_CoreLoginResult) _then) = __$CoreLoginResultCopyWithImpl;
@override @useResult
$Res call({
 bool success, String? message, CoreAccount? account
});


@override $CoreAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$CoreLoginResultCopyWithImpl<$Res>
    implements _$CoreLoginResultCopyWith<$Res> {
  __$CoreLoginResultCopyWithImpl(this._self, this._then);

  final _CoreLoginResult _self;
  final $Res Function(_CoreLoginResult) _then;

/// Create a copy of CoreLoginResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = freezed,Object? account = freezed,}) {
  return _then(_CoreLoginResult(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as CoreAccount?,
  ));
}

/// Create a copy of CoreLoginResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $CoreAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}

// dart format on
