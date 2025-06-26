import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
import 'package:qiita_client_app/features/qiita_items/domain/repository/qiita_item_repository.dart';

class QiitaItemsUseCase {
  const QiitaItemsUseCase(this._repository);

  final QiitaItemRepository _repository;

  Future<List<QiitaItem>> call({
    int page = 1,
    int perPage = 20,
  }) => _repository.fetchItems(page: page, perPage: perPage);
}