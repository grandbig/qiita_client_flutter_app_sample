import 'package:qiita_client_app/features/qiita_items/data/model/qiita_item_model.dart';

import '../../domain/entity/qiita_item.dart';
import '../../domain/repository/qiita_item_repository.dart';
import '../datasource/qiita_api_client.dart';

class QiitaItemRepositoryImpl implements QiitaItemRepository {
  QiitaItemRepositoryImpl(this._apiClient);
  final QiitaApiClient _apiClient;

  @override
  Future<List<QiitaItem>> fetchItems({
    int page = 1,
    int perPage = 20,
  }) async {
    // APIクライアントを呼び出してData層のモデルを取得
    final models = await _apiClient.fetchItems(page: page, perPage: perPage);

    // Data層のモデル(Model)からDomain層のエンティティ(Entity)へ変換
    return models.map((e) => e.toEntity()).toList();
  }

}