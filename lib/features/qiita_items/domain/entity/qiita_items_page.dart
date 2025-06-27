import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';

class QiitaItemsPage {
  const QiitaItemsPage({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<QiitaItem> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  QiitaItemsPage copyWith({
    List<QiitaItem>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return QiitaItemsPage(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  static const empty = QiitaItemsPage(
    items: [],
    currentPage: 0,
    hasMore: true,
    isLoadingMore: false,
  );
}