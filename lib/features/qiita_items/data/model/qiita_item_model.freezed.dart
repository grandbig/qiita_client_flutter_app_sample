// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qiita_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QiitaItemModel {

 String get title; int get likesCount; UserModel get user;
/// Create a copy of QiitaItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QiitaItemModelCopyWith<QiitaItemModel> get copyWith => _$QiitaItemModelCopyWithImpl<QiitaItemModel>(this as QiitaItemModel, _$identity);

  /// Serializes this QiitaItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QiitaItemModel&&(identical(other.title, title) || other.title == title)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,likesCount,user);

@override
String toString() {
  return 'QiitaItemModel(title: $title, likesCount: $likesCount, user: $user)';
}


}

/// @nodoc
abstract mixin class $QiitaItemModelCopyWith<$Res>  {
  factory $QiitaItemModelCopyWith(QiitaItemModel value, $Res Function(QiitaItemModel) _then) = _$QiitaItemModelCopyWithImpl;
@useResult
$Res call({
 String title, int likesCount, UserModel user
});


$UserModelCopyWith<$Res> get user;

}
/// @nodoc
class _$QiitaItemModelCopyWithImpl<$Res>
    implements $QiitaItemModelCopyWith<$Res> {
  _$QiitaItemModelCopyWithImpl(this._self, this._then);

  final QiitaItemModel _self;
  final $Res Function(QiitaItemModel) _then;

/// Create a copy of QiitaItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? likesCount = null,Object? user = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,
  ));
}
/// Create a copy of QiitaItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get user {
  
  return $UserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _QiitaItemModel implements QiitaItemModel {
  const _QiitaItemModel({required this.title, required this.likesCount, required this.user});
  factory _QiitaItemModel.fromJson(Map<String, dynamic> json) => _$QiitaItemModelFromJson(json);

@override final  String title;
@override final  int likesCount;
@override final  UserModel user;

/// Create a copy of QiitaItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QiitaItemModelCopyWith<_QiitaItemModel> get copyWith => __$QiitaItemModelCopyWithImpl<_QiitaItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QiitaItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QiitaItemModel&&(identical(other.title, title) || other.title == title)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,likesCount,user);

@override
String toString() {
  return 'QiitaItemModel(title: $title, likesCount: $likesCount, user: $user)';
}


}

/// @nodoc
abstract mixin class _$QiitaItemModelCopyWith<$Res> implements $QiitaItemModelCopyWith<$Res> {
  factory _$QiitaItemModelCopyWith(_QiitaItemModel value, $Res Function(_QiitaItemModel) _then) = __$QiitaItemModelCopyWithImpl;
@override @useResult
$Res call({
 String title, int likesCount, UserModel user
});


@override $UserModelCopyWith<$Res> get user;

}
/// @nodoc
class __$QiitaItemModelCopyWithImpl<$Res>
    implements _$QiitaItemModelCopyWith<$Res> {
  __$QiitaItemModelCopyWithImpl(this._self, this._then);

  final _QiitaItemModel _self;
  final $Res Function(_QiitaItemModel) _then;

/// Create a copy of QiitaItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? likesCount = null,Object? user = null,}) {
  return _then(_QiitaItemModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,
  ));
}

/// Create a copy of QiitaItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get user {
  
  return $UserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$UserModel {

 String get id;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'UserModel(id: $id)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _UserModel implements UserModel {
  const _UserModel({required this.id});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'UserModel(id: $id)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
