// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qiita_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QiitaItemModel _$QiitaItemModelFromJson(Map<String, dynamic> json) =>
    _QiitaItemModel(
      title: json['title'] as String,
      likesCount: (json['likes_count'] as num).toInt(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QiitaItemModelToJson(_QiitaItemModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'likes_count': instance.likesCount,
      'user': instance.user,
    };

_UserModel _$UserModelFromJson(Map<String, dynamic> json) =>
    _UserModel(id: json['id'] as String);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{'id': instance.id};
