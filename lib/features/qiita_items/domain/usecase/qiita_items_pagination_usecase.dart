import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_items_page.dart';
import 'package:qiita_client_app/features/qiita_items/domain/repository/qiita_item_repository.dart';

class QiitaItemsPaginationUseCase {
  const QiitaItemsPaginationUseCase(this._repository);

  final QiitaItemRepository _repository;

  Future<QiitaItemsPage> loadInitialPage({
    int perPage = 20,
  }) async {
    final items = await _repository.fetchItems(page: 1, perPage: perPage);
    
    return QiitaItemsPage(
      items: items,
      currentPage: 1,
      hasMore: items.length == perPage, // 要求した件数と同じなら次のページがある可能性
      isLoadingMore: false,
    );
  }

  Future<QiitaItemsPage> loadNextPage(
    QiitaItemsPage currentPage, {
    int perPage = 20,
  }) async {
    if (!currentPage.hasMore) {
      return currentPage;
    }

    final nextPageNumber = currentPage.currentPage + 1;
    final newItems = await _repository.fetchItems(
      page: nextPageNumber,
      perPage: perPage,
    );

    return QiitaItemsPage(
      items: [...currentPage.items, ...newItems],
      currentPage: nextPageNumber,
      hasMore: newItems.length == perPage, // 要求した件数より少なければ最後のページ
      isLoadingMore: false,
    );
  }
}