// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'danmaku_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreDanmakuBlockDataModel {

 List<CoreSimpleRule> get rule; List<CoreSimpleRule> get rule1; List<CoreSimpleRule> get rule2; String? get toast; int? get valid; int? get ver;
/// Create a copy of CoreDanmakuBlockDataModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreDanmakuBlockDataModelCopyWith<CoreDanmakuBlockDataModel> get copyWith => _$CoreDanmakuBlockDataModelCopyWithImpl<CoreDanmakuBlockDataModel>(this as CoreDanmakuBlockDataModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreDanmakuBlockDataModel&&const DeepCollectionEquality().equals(other.rule, rule)&&const DeepCollectionEquality().equals(other.rule1, rule1)&&const DeepCollectionEquality().equals(other.rule2, rule2)&&(identical(other.toast, toast) || other.toast == toast)&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.ver, ver) || other.ver == ver));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rule),const DeepCollectionEquality().hash(rule1),const DeepCollectionEquality().hash(rule2),toast,valid,ver);

@override
String toString() {
  return 'CoreDanmakuBlockDataModel(rule: $rule, rule1: $rule1, rule2: $rule2, toast: $toast, valid: $valid, ver: $ver)';
}


}

/// @nodoc
abstract mixin class $CoreDanmakuBlockDataModelCopyWith<$Res>  {
  factory $CoreDanmakuBlockDataModelCopyWith(CoreDanmakuBlockDataModel value, $Res Function(CoreDanmakuBlockDataModel) _then) = _$CoreDanmakuBlockDataModelCopyWithImpl;
@useResult
$Res call({
 List<CoreSimpleRule> rule, List<CoreSimpleRule> rule1, List<CoreSimpleRule> rule2, String? toast, int? valid, int? ver
});




}
/// @nodoc
class _$CoreDanmakuBlockDataModelCopyWithImpl<$Res>
    implements $CoreDanmakuBlockDataModelCopyWith<$Res> {
  _$CoreDanmakuBlockDataModelCopyWithImpl(this._self, this._then);

  final CoreDanmakuBlockDataModel _self;
  final $Res Function(CoreDanmakuBlockDataModel) _then;

/// Create a copy of CoreDanmakuBlockDataModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rule = null,Object? rule1 = null,Object? rule2 = null,Object? toast = freezed,Object? valid = freezed,Object? ver = freezed,}) {
  return _then(_self.copyWith(
rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as List<CoreSimpleRule>,rule1: null == rule1 ? _self.rule1 : rule1 // ignore: cast_nullable_to_non_nullable
as List<CoreSimpleRule>,rule2: null == rule2 ? _self.rule2 : rule2 // ignore: cast_nullable_to_non_nullable
as List<CoreSimpleRule>,toast: freezed == toast ? _self.toast : toast // ignore: cast_nullable_to_non_nullable
as String?,valid: freezed == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as int?,ver: freezed == ver ? _self.ver : ver // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreDanmakuBlockDataModel].
extension CoreDanmakuBlockDataModelPatterns on CoreDanmakuBlockDataModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreDanmakuBlockDataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreDanmakuBlockDataModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreDanmakuBlockDataModel value)  $default,){
final _that = this;
switch (_that) {
case _CoreDanmakuBlockDataModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreDanmakuBlockDataModel value)?  $default,){
final _that = this;
switch (_that) {
case _CoreDanmakuBlockDataModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CoreSimpleRule> rule,  List<CoreSimpleRule> rule1,  List<CoreSimpleRule> rule2,  String? toast,  int? valid,  int? ver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreDanmakuBlockDataModel() when $default != null:
return $default(_that.rule,_that.rule1,_that.rule2,_that.toast,_that.valid,_that.ver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CoreSimpleRule> rule,  List<CoreSimpleRule> rule1,  List<CoreSimpleRule> rule2,  String? toast,  int? valid,  int? ver)  $default,) {final _that = this;
switch (_that) {
case _CoreDanmakuBlockDataModel():
return $default(_that.rule,_that.rule1,_that.rule2,_that.toast,_that.valid,_that.ver);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CoreSimpleRule> rule,  List<CoreSimpleRule> rule1,  List<CoreSimpleRule> rule2,  String? toast,  int? valid,  int? ver)?  $default,) {final _that = this;
switch (_that) {
case _CoreDanmakuBlockDataModel() when $default != null:
return $default(_that.rule,_that.rule1,_that.rule2,_that.toast,_that.valid,_that.ver);case _:
  return null;

}
}

}

/// @nodoc


class _CoreDanmakuBlockDataModel implements CoreDanmakuBlockDataModel {
  const _CoreDanmakuBlockDataModel({required final  List<CoreSimpleRule> rule, required final  List<CoreSimpleRule> rule1, required final  List<CoreSimpleRule> rule2, this.toast, this.valid, this.ver}): _rule = rule,_rule1 = rule1,_rule2 = rule2;
  

 final  List<CoreSimpleRule> _rule;
@override List<CoreSimpleRule> get rule {
  if (_rule is EqualUnmodifiableListView) return _rule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rule);
}

 final  List<CoreSimpleRule> _rule1;
@override List<CoreSimpleRule> get rule1 {
  if (_rule1 is EqualUnmodifiableListView) return _rule1;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rule1);
}

 final  List<CoreSimpleRule> _rule2;
@override List<CoreSimpleRule> get rule2 {
  if (_rule2 is EqualUnmodifiableListView) return _rule2;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rule2);
}

@override final  String? toast;
@override final  int? valid;
@override final  int? ver;

/// Create a copy of CoreDanmakuBlockDataModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreDanmakuBlockDataModelCopyWith<_CoreDanmakuBlockDataModel> get copyWith => __$CoreDanmakuBlockDataModelCopyWithImpl<_CoreDanmakuBlockDataModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreDanmakuBlockDataModel&&const DeepCollectionEquality().equals(other._rule, _rule)&&const DeepCollectionEquality().equals(other._rule1, _rule1)&&const DeepCollectionEquality().equals(other._rule2, _rule2)&&(identical(other.toast, toast) || other.toast == toast)&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.ver, ver) || other.ver == ver));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rule),const DeepCollectionEquality().hash(_rule1),const DeepCollectionEquality().hash(_rule2),toast,valid,ver);

@override
String toString() {
  return 'CoreDanmakuBlockDataModel(rule: $rule, rule1: $rule1, rule2: $rule2, toast: $toast, valid: $valid, ver: $ver)';
}


}

/// @nodoc
abstract mixin class _$CoreDanmakuBlockDataModelCopyWith<$Res> implements $CoreDanmakuBlockDataModelCopyWith<$Res> {
  factory _$CoreDanmakuBlockDataModelCopyWith(_CoreDanmakuBlockDataModel value, $Res Function(_CoreDanmakuBlockDataModel) _then) = __$CoreDanmakuBlockDataModelCopyWithImpl;
@override @useResult
$Res call({
 List<CoreSimpleRule> rule, List<CoreSimpleRule> rule1, List<CoreSimpleRule> rule2, String? toast, int? valid, int? ver
});




}
/// @nodoc
class __$CoreDanmakuBlockDataModelCopyWithImpl<$Res>
    implements _$CoreDanmakuBlockDataModelCopyWith<$Res> {
  __$CoreDanmakuBlockDataModelCopyWithImpl(this._self, this._then);

  final _CoreDanmakuBlockDataModel _self;
  final $Res Function(_CoreDanmakuBlockDataModel) _then;

/// Create a copy of CoreDanmakuBlockDataModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rule = null,Object? rule1 = null,Object? rule2 = null,Object? toast = freezed,Object? valid = freezed,Object? ver = freezed,}) {
  return _then(_CoreDanmakuBlockDataModel(
rule: null == rule ? _self._rule : rule // ignore: cast_nullable_to_non_nullable
as List<CoreSimpleRule>,rule1: null == rule1 ? _self._rule1 : rule1 // ignore: cast_nullable_to_non_nullable
as List<CoreSimpleRule>,rule2: null == rule2 ? _self._rule2 : rule2 // ignore: cast_nullable_to_non_nullable
as List<CoreSimpleRule>,toast: freezed == toast ? _self.toast : toast // ignore: cast_nullable_to_non_nullable
as String?,valid: freezed == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as int?,ver: freezed == ver ? _self.ver : ver // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$CoreSimpleRule {

 int get id; int get type; String get filter;
/// Create a copy of CoreSimpleRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreSimpleRuleCopyWith<CoreSimpleRule> get copyWith => _$CoreSimpleRuleCopyWithImpl<CoreSimpleRule>(this as CoreSimpleRule, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreSimpleRule&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,filter);

@override
String toString() {
  return 'CoreSimpleRule(id: $id, type: $type, filter: $filter)';
}


}

/// @nodoc
abstract mixin class $CoreSimpleRuleCopyWith<$Res>  {
  factory $CoreSimpleRuleCopyWith(CoreSimpleRule value, $Res Function(CoreSimpleRule) _then) = _$CoreSimpleRuleCopyWithImpl;
@useResult
$Res call({
 int id, int type, String filter
});




}
/// @nodoc
class _$CoreSimpleRuleCopyWithImpl<$Res>
    implements $CoreSimpleRuleCopyWith<$Res> {
  _$CoreSimpleRuleCopyWithImpl(this._self, this._then);

  final CoreSimpleRule _self;
  final $Res Function(CoreSimpleRule) _then;

/// Create a copy of CoreSimpleRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? filter = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreSimpleRule].
extension CoreSimpleRulePatterns on CoreSimpleRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreSimpleRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreSimpleRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreSimpleRule value)  $default,){
final _that = this;
switch (_that) {
case _CoreSimpleRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreSimpleRule value)?  $default,){
final _that = this;
switch (_that) {
case _CoreSimpleRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int type,  String filter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreSimpleRule() when $default != null:
return $default(_that.id,_that.type,_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int type,  String filter)  $default,) {final _that = this;
switch (_that) {
case _CoreSimpleRule():
return $default(_that.id,_that.type,_that.filter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int type,  String filter)?  $default,) {final _that = this;
switch (_that) {
case _CoreSimpleRule() when $default != null:
return $default(_that.id,_that.type,_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class _CoreSimpleRule implements CoreSimpleRule {
  const _CoreSimpleRule({required this.id, required this.type, required this.filter});
  

@override final  int id;
@override final  int type;
@override final  String filter;

/// Create a copy of CoreSimpleRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreSimpleRuleCopyWith<_CoreSimpleRule> get copyWith => __$CoreSimpleRuleCopyWithImpl<_CoreSimpleRule>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreSimpleRule&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,filter);

@override
String toString() {
  return 'CoreSimpleRule(id: $id, type: $type, filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$CoreSimpleRuleCopyWith<$Res> implements $CoreSimpleRuleCopyWith<$Res> {
  factory _$CoreSimpleRuleCopyWith(_CoreSimpleRule value, $Res Function(_CoreSimpleRule) _then) = __$CoreSimpleRuleCopyWithImpl;
@override @useResult
$Res call({
 int id, int type, String filter
});




}
/// @nodoc
class __$CoreSimpleRuleCopyWithImpl<$Res>
    implements _$CoreSimpleRuleCopyWith<$Res> {
  __$CoreSimpleRuleCopyWithImpl(this._self, this._then);

  final _CoreSimpleRule _self;
  final $Res Function(_CoreSimpleRule) _then;

/// Create a copy of CoreSimpleRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? filter = null,}) {
  return _then(_CoreSimpleRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
