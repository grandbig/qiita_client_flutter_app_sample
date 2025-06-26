import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';

part 'qiita_item_model.freezed.dart';
part 'qiita_item_model.g.dart';

@freezed
sealed class QiitaItemModel with _$QiitaItemModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory QiitaItemModel({
    required String title,
    required int likesCount,
    required UserModel user,
  }) = _QiitaItemModel;

  factory QiitaItemModel.fromJson(Map<String, dynamic> json) =>
      _$QiitaItemModelFromJson(json);
}

@freezed
sealed class UserModel with _$UserModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserModel({
    required String id,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension QiitaItemModelX on QiitaItemModel {
  QiitaItem toEntity() => QiitaItem(
    title: title,
    likesCount: likesCount,
    userId: user.id,
  );
}