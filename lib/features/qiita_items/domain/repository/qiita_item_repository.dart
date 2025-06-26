import '../entity/qiita_item.dart';

abstract interface class QiitaItemRepository {
  Future<List<QiitaItem>> fetchItems({
    int page = 1,
    int perPage = 20,
  });
}