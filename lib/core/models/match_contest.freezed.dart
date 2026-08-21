// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_contest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreSeason {

 String? get title; String? get logo;
/// Create a copy of CoreSeason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreSeasonCopyWith<CoreSeason> get copyWith => _$CoreSeasonCopyWithImpl<CoreSeason>(this as CoreSeason, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreSeason&&(identical(other.title, title) || other.title == title)&&(identical(other.logo, logo) || other.logo == logo));
}


@override
int get hashCode => Object.hash(runtimeType,title,logo);

@override
String toString() {
  return 'CoreSeason(title: $title, logo: $logo)';
}


}

/// @nodoc
abstract mixin class $CoreSeasonCopyWith<$Res>  {
  factory $CoreSeasonCopyWith(CoreSeason value, $Res Function(CoreSeason) _then) = _$CoreSeasonCopyWithImpl;
@useResult
$Res call({
 String? title, String? logo
});




}
/// @nodoc
class _$CoreSeasonCopyWithImpl<$Res>
    implements $CoreSeasonCopyWith<$Res> {
  _$CoreSeasonCopyWithImpl(this._self, this._then);

  final CoreSeason _self;
  final $Res Function(CoreSeason) _then;

/// Create a copy of CoreSeason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? logo = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreSeason].
extension CoreSeasonPatterns on CoreSeason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreSeason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreSeason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreSeason value)  $default,){
final _that = this;
switch (_that) {
case _CoreSeason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreSeason value)?  $default,){
final _that = this;
switch (_that) {
case _CoreSeason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? logo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreSeason() when $default != null:
return $default(_that.title,_that.logo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? logo)  $default,) {final _that = this;
switch (_that) {
case _CoreSeason():
return $default(_that.title,_that.logo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? logo)?  $default,) {final _that = this;
switch (_that) {
case _CoreSeason() when $default != null:
return $default(_that.title,_that.logo);case _:
  return null;

}
}

}

/// @nodoc


class _CoreSeason implements CoreSeason {
  const _CoreSeason({this.title, this.logo});
  

@override final  String? title;
@override final  String? logo;

/// Create a copy of CoreSeason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreSeasonCopyWith<_CoreSeason> get copyWith => __$CoreSeasonCopyWithImpl<_CoreSeason>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreSeason&&(identical(other.title, title) || other.title == title)&&(identical(other.logo, logo) || other.logo == logo));
}


@override
int get hashCode => Object.hash(runtimeType,title,logo);

@override
String toString() {
  return 'CoreSeason(title: $title, logo: $logo)';
}


}

/// @nodoc
abstract mixin class _$CoreSeasonCopyWith<$Res> implements $CoreSeasonCopyWith<$Res> {
  factory _$CoreSeasonCopyWith(_CoreSeason value, $Res Function(_CoreSeason) _then) = __$CoreSeasonCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? logo
});




}
/// @nodoc
class __$CoreSeasonCopyWithImpl<$Res>
    implements _$CoreSeasonCopyWith<$Res> {
  __$CoreSeasonCopyWithImpl(this._self, this._then);

  final _CoreSeason _self;
  final $Res Function(_CoreSeason) _then;

/// Create a copy of CoreSeason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? logo = freezed,}) {
  return _then(_CoreSeason(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CoreMatchTeam {

 String? get title; String? get logo;
/// Create a copy of CoreMatchTeam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreMatchTeamCopyWith<CoreMatchTeam> get copyWith => _$CoreMatchTeamCopyWithImpl<CoreMatchTeam>(this as CoreMatchTeam, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreMatchTeam&&(identical(other.title, title) || other.title == title)&&(identical(other.logo, logo) || other.logo == logo));
}


@override
int get hashCode => Object.hash(runtimeType,title,logo);

@override
String toString() {
  return 'CoreMatchTeam(title: $title, logo: $logo)';
}


}

/// @nodoc
abstract mixin class $CoreMatchTeamCopyWith<$Res>  {
  factory $CoreMatchTeamCopyWith(CoreMatchTeam value, $Res Function(CoreMatchTeam) _then) = _$CoreMatchTeamCopyWithImpl;
@useResult
$Res call({
 String? title, String? logo
});




}
/// @nodoc
class _$CoreMatchTeamCopyWithImpl<$Res>
    implements $CoreMatchTeamCopyWith<$Res> {
  _$CoreMatchTeamCopyWithImpl(this._self, this._then);

  final CoreMatchTeam _self;
  final $Res Function(CoreMatchTeam) _then;

/// Create a copy of CoreMatchTeam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? logo = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreMatchTeam].
extension CoreMatchTeamPatterns on CoreMatchTeam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreMatchTeam value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreMatchTeam() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreMatchTeam value)  $default,){
final _that = this;
switch (_that) {
case _CoreMatchTeam():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreMatchTeam value)?  $default,){
final _that = this;
switch (_that) {
case _CoreMatchTeam() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? logo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreMatchTeam() when $default != null:
return $default(_that.title,_that.logo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? logo)  $default,) {final _that = this;
switch (_that) {
case _CoreMatchTeam():
return $default(_that.title,_that.logo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? logo)?  $default,) {final _that = this;
switch (_that) {
case _CoreMatchTeam() when $default != null:
return $default(_that.title,_that.logo);case _:
  return null;

}
}

}

/// @nodoc


class _CoreMatchTeam implements CoreMatchTeam {
  const _CoreMatchTeam({this.title, this.logo});
  

@override final  String? title;
@override final  String? logo;

/// Create a copy of CoreMatchTeam
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreMatchTeamCopyWith<_CoreMatchTeam> get copyWith => __$CoreMatchTeamCopyWithImpl<_CoreMatchTeam>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreMatchTeam&&(identical(other.title, title) || other.title == title)&&(identical(other.logo, logo) || other.logo == logo));
}


@override
int get hashCode => Object.hash(runtimeType,title,logo);

@override
String toString() {
  return 'CoreMatchTeam(title: $title, logo: $logo)';
}


}

/// @nodoc
abstract mixin class _$CoreMatchTeamCopyWith<$Res> implements $CoreMatchTeamCopyWith<$Res> {
  factory _$CoreMatchTeamCopyWith(_CoreMatchTeam value, $Res Function(_CoreMatchTeam) _then) = __$CoreMatchTeamCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? logo
});




}
/// @nodoc
class __$CoreMatchTeamCopyWithImpl<$Res>
    implements _$CoreMatchTeamCopyWith<$Res> {
  __$CoreMatchTeamCopyWithImpl(this._self, this._then);

  final _CoreMatchTeam _self;
  final $Res Function(_CoreMatchTeam) _then;

/// Create a copy of CoreMatchTeam
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? logo = freezed,}) {
  return _then(_CoreMatchTeam(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CoreMatchContest {

 String? get gameStage; int? get stime; int? get homeId; int? get awayId; int? get homeScore; int? get awayScore; int? get liveRoom; CoreSeason? get season; CoreMatchTeam? get homeTeam; CoreMatchTeam? get awayTeam; int? get contestStatus;
/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreMatchContestCopyWith<CoreMatchContest> get copyWith => _$CoreMatchContestCopyWithImpl<CoreMatchContest>(this as CoreMatchContest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreMatchContest&&(identical(other.gameStage, gameStage) || other.gameStage == gameStage)&&(identical(other.stime, stime) || other.stime == stime)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore)&&(identical(other.liveRoom, liveRoom) || other.liveRoom == liveRoom)&&(identical(other.season, season) || other.season == season)&&(identical(other.homeTeam, homeTeam) || other.homeTeam == homeTeam)&&(identical(other.awayTeam, awayTeam) || other.awayTeam == awayTeam)&&(identical(other.contestStatus, contestStatus) || other.contestStatus == contestStatus));
}


@override
int get hashCode => Object.hash(runtimeType,gameStage,stime,homeId,awayId,homeScore,awayScore,liveRoom,season,homeTeam,awayTeam,contestStatus);

@override
String toString() {
  return 'CoreMatchContest(gameStage: $gameStage, stime: $stime, homeId: $homeId, awayId: $awayId, homeScore: $homeScore, awayScore: $awayScore, liveRoom: $liveRoom, season: $season, homeTeam: $homeTeam, awayTeam: $awayTeam, contestStatus: $contestStatus)';
}


}

/// @nodoc
abstract mixin class $CoreMatchContestCopyWith<$Res>  {
  factory $CoreMatchContestCopyWith(CoreMatchContest value, $Res Function(CoreMatchContest) _then) = _$CoreMatchContestCopyWithImpl;
@useResult
$Res call({
 String? gameStage, int? stime, int? homeId, int? awayId, int? homeScore, int? awayScore, int? liveRoom, CoreSeason? season, CoreMatchTeam? homeTeam, CoreMatchTeam? awayTeam, int? contestStatus
});


$CoreSeasonCopyWith<$Res>? get season;$CoreMatchTeamCopyWith<$Res>? get homeTeam;$CoreMatchTeamCopyWith<$Res>? get awayTeam;

}
/// @nodoc
class _$CoreMatchContestCopyWithImpl<$Res>
    implements $CoreMatchContestCopyWith<$Res> {
  _$CoreMatchContestCopyWithImpl(this._self, this._then);

  final CoreMatchContest _self;
  final $Res Function(CoreMatchContest) _then;

/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gameStage = freezed,Object? stime = freezed,Object? homeId = freezed,Object? awayId = freezed,Object? homeScore = freezed,Object? awayScore = freezed,Object? liveRoom = freezed,Object? season = freezed,Object? homeTeam = freezed,Object? awayTeam = freezed,Object? contestStatus = freezed,}) {
  return _then(_self.copyWith(
gameStage: freezed == gameStage ? _self.gameStage : gameStage // ignore: cast_nullable_to_non_nullable
as String?,stime: freezed == stime ? _self.stime : stime // ignore: cast_nullable_to_non_nullable
as int?,homeId: freezed == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int?,awayId: freezed == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int?,homeScore: freezed == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int?,awayScore: freezed == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int?,liveRoom: freezed == liveRoom ? _self.liveRoom : liveRoom // ignore: cast_nullable_to_non_nullable
as int?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as CoreSeason?,homeTeam: freezed == homeTeam ? _self.homeTeam : homeTeam // ignore: cast_nullable_to_non_nullable
as CoreMatchTeam?,awayTeam: freezed == awayTeam ? _self.awayTeam : awayTeam // ignore: cast_nullable_to_non_nullable
as CoreMatchTeam?,contestStatus: freezed == contestStatus ? _self.contestStatus : contestStatus // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreSeasonCopyWith<$Res>? get season {
    if (_self.season == null) {
    return null;
  }

  return $CoreSeasonCopyWith<$Res>(_self.season!, (value) {
    return _then(_self.copyWith(season: value));
  });
}/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreMatchTeamCopyWith<$Res>? get homeTeam {
    if (_self.homeTeam == null) {
    return null;
  }

  return $CoreMatchTeamCopyWith<$Res>(_self.homeTeam!, (value) {
    return _then(_self.copyWith(homeTeam: value));
  });
}/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreMatchTeamCopyWith<$Res>? get awayTeam {
    if (_self.awayTeam == null) {
    return null;
  }

  return $CoreMatchTeamCopyWith<$Res>(_self.awayTeam!, (value) {
    return _then(_self.copyWith(awayTeam: value));
  });
}
}


/// Adds pattern-matching-related methods to [CoreMatchContest].
extension CoreMatchContestPatterns on CoreMatchContest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreMatchContest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreMatchContest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreMatchContest value)  $default,){
final _that = this;
switch (_that) {
case _CoreMatchContest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreMatchContest value)?  $default,){
final _that = this;
switch (_that) {
case _CoreMatchContest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? gameStage,  int? stime,  int? homeId,  int? awayId,  int? homeScore,  int? awayScore,  int? liveRoom,  CoreSeason? season,  CoreMatchTeam? homeTeam,  CoreMatchTeam? awayTeam,  int? contestStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreMatchContest() when $default != null:
return $default(_that.gameStage,_that.stime,_that.homeId,_that.awayId,_that.homeScore,_that.awayScore,_that.liveRoom,_that.season,_that.homeTeam,_that.awayTeam,_that.contestStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? gameStage,  int? stime,  int? homeId,  int? awayId,  int? homeScore,  int? awayScore,  int? liveRoom,  CoreSeason? season,  CoreMatchTeam? homeTeam,  CoreMatchTeam? awayTeam,  int? contestStatus)  $default,) {final _that = this;
switch (_that) {
case _CoreMatchContest():
return $default(_that.gameStage,_that.stime,_that.homeId,_that.awayId,_that.homeScore,_that.awayScore,_that.liveRoom,_that.season,_that.homeTeam,_that.awayTeam,_that.contestStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? gameStage,  int? stime,  int? homeId,  int? awayId,  int? homeScore,  int? awayScore,  int? liveRoom,  CoreSeason? season,  CoreMatchTeam? homeTeam,  CoreMatchTeam? awayTeam,  int? contestStatus)?  $default,) {final _that = this;
switch (_that) {
case _CoreMatchContest() when $default != null:
return $default(_that.gameStage,_that.stime,_that.homeId,_that.awayId,_that.homeScore,_that.awayScore,_that.liveRoom,_that.season,_that.homeTeam,_that.awayTeam,_that.contestStatus);case _:
  return null;

}
}

}

/// @nodoc


class _CoreMatchContest implements CoreMatchContest {
  const _CoreMatchContest({this.gameStage, this.stime, this.homeId, this.awayId, this.homeScore, this.awayScore, this.liveRoom, this.season, this.homeTeam, this.awayTeam, this.contestStatus});
  

@override final  String? gameStage;
@override final  int? stime;
@override final  int? homeId;
@override final  int? awayId;
@override final  int? homeScore;
@override final  int? awayScore;
@override final  int? liveRoom;
@override final  CoreSeason? season;
@override final  CoreMatchTeam? homeTeam;
@override final  CoreMatchTeam? awayTeam;
@override final  int? contestStatus;

/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreMatchContestCopyWith<_CoreMatchContest> get copyWith => __$CoreMatchContestCopyWithImpl<_CoreMatchContest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreMatchContest&&(identical(other.gameStage, gameStage) || other.gameStage == gameStage)&&(identical(other.stime, stime) || other.stime == stime)&&(identical(other.homeId, homeId) || other.homeId == homeId)&&(identical(other.awayId, awayId) || other.awayId == awayId)&&(identical(other.homeScore, homeScore) || other.homeScore == homeScore)&&(identical(other.awayScore, awayScore) || other.awayScore == awayScore)&&(identical(other.liveRoom, liveRoom) || other.liveRoom == liveRoom)&&(identical(other.season, season) || other.season == season)&&(identical(other.homeTeam, homeTeam) || other.homeTeam == homeTeam)&&(identical(other.awayTeam, awayTeam) || other.awayTeam == awayTeam)&&(identical(other.contestStatus, contestStatus) || other.contestStatus == contestStatus));
}


@override
int get hashCode => Object.hash(runtimeType,gameStage,stime,homeId,awayId,homeScore,awayScore,liveRoom,season,homeTeam,awayTeam,contestStatus);

@override
String toString() {
  return 'CoreMatchContest(gameStage: $gameStage, stime: $stime, homeId: $homeId, awayId: $awayId, homeScore: $homeScore, awayScore: $awayScore, liveRoom: $liveRoom, season: $season, homeTeam: $homeTeam, awayTeam: $awayTeam, contestStatus: $contestStatus)';
}


}

/// @nodoc
abstract mixin class _$CoreMatchContestCopyWith<$Res> implements $CoreMatchContestCopyWith<$Res> {
  factory _$CoreMatchContestCopyWith(_CoreMatchContest value, $Res Function(_CoreMatchContest) _then) = __$CoreMatchContestCopyWithImpl;
@override @useResult
$Res call({
 String? gameStage, int? stime, int? homeId, int? awayId, int? homeScore, int? awayScore, int? liveRoom, CoreSeason? season, CoreMatchTeam? homeTeam, CoreMatchTeam? awayTeam, int? contestStatus
});


@override $CoreSeasonCopyWith<$Res>? get season;@override $CoreMatchTeamCopyWith<$Res>? get homeTeam;@override $CoreMatchTeamCopyWith<$Res>? get awayTeam;

}
/// @nodoc
class __$CoreMatchContestCopyWithImpl<$Res>
    implements _$CoreMatchContestCopyWith<$Res> {
  __$CoreMatchContestCopyWithImpl(this._self, this._then);

  final _CoreMatchContest _self;
  final $Res Function(_CoreMatchContest) _then;

/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gameStage = freezed,Object? stime = freezed,Object? homeId = freezed,Object? awayId = freezed,Object? homeScore = freezed,Object? awayScore = freezed,Object? liveRoom = freezed,Object? season = freezed,Object? homeTeam = freezed,Object? awayTeam = freezed,Object? contestStatus = freezed,}) {
  return _then(_CoreMatchContest(
gameStage: freezed == gameStage ? _self.gameStage : gameStage // ignore: cast_nullable_to_non_nullable
as String?,stime: freezed == stime ? _self.stime : stime // ignore: cast_nullable_to_non_nullable
as int?,homeId: freezed == homeId ? _self.homeId : homeId // ignore: cast_nullable_to_non_nullable
as int?,awayId: freezed == awayId ? _self.awayId : awayId // ignore: cast_nullable_to_non_nullable
as int?,homeScore: freezed == homeScore ? _self.homeScore : homeScore // ignore: cast_nullable_to_non_nullable
as int?,awayScore: freezed == awayScore ? _self.awayScore : awayScore // ignore: cast_nullable_to_non_nullable
as int?,liveRoom: freezed == liveRoom ? _self.liveRoom : liveRoom // ignore: cast_nullable_to_non_nullable
as int?,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as CoreSeason?,homeTeam: freezed == homeTeam ? _self.homeTeam : homeTeam // ignore: cast_nullable_to_non_nullable
as CoreMatchTeam?,awayTeam: freezed == awayTeam ? _self.awayTeam : awayTeam // ignore: cast_nullable_to_non_nullable
as CoreMatchTeam?,contestStatus: freezed == contestStatus ? _self.contestStatus : contestStatus // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreSeasonCopyWith<$Res>? get season {
    if (_self.season == null) {
    return null;
  }

  return $CoreSeasonCopyWith<$Res>(_self.season!, (value) {
    return _then(_self.copyWith(season: value));
  });
}/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreMatchTeamCopyWith<$Res>? get homeTeam {
    if (_self.homeTeam == null) {
    return null;
  }

  return $CoreMatchTeamCopyWith<$Res>(_self.homeTeam!, (value) {
    return _then(_self.copyWith(homeTeam: value));
  });
}/// Create a copy of CoreMatchContest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreMatchTeamCopyWith<$Res>? get awayTeam {
    if (_self.awayTeam == null) {
    return null;
  }

  return $CoreMatchTeamCopyWith<$Res>(_self.awayTeam!, (value) {
    return _then(_self.copyWith(awayTeam: value));
  });
}
}

// dart format on
