import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_items_page.dart';
import 'package:qiita_client_app/features/qiita_items/domain/repository/qiita_item_repository.dart';
import 'package:qiita_client_app/features/qiita_items/domain/usecase/qiita_items_pagination_usecase.dart';

import 'qiita_items_pagination_usecase_test.mocks.dart';

@GenerateMocks([QiitaItemRepository])
void main() {
  group('QiitaItemsPaginationUseCase', () {
    late MockQiitaItemRepository mockRepository;
    late QiitaItemsPaginationUseCase useCase;

    setUp(() {
      mockRepository = MockQiitaItemRepository();
      useCase = QiitaItemsPaginationUseCase(mockRepository);
    });

    group('loadInitialPage', () {
      test('returns first page with hasMore=true when full page returned', () async {
        const testItems = [
          QiitaItem(title: 'Article 1', likesCount: 10, userId: 'user1'),
          QiitaItem(title: 'Article 2', likesCount: 5, userId: 'user2'),
        ];

        when(mockRepository.fetchItems(page: 1, perPage: 20))
            .thenAnswer((_) async => List.generate(20, (i) => testItems[i % 2]));

        final result = await useCase.loadInitialPage();

        expect(result.items, hasLength(20));
        expect(result.currentPage, 1);
        expect(result.hasMore, isTrue);
        expect(result.isLoadingMore, isFalse);
      });

      test('returns first page with hasMore=false when partial page returned', () async {
        const testItems = [
          QiitaItem(title: 'Article 1', likesCount: 10, userId: 'user1'),
        ];

        when(mockRepository.fetchItems(page: 1, perPage: 20))
            .thenAnswer((_) async => testItems);

        final result = await useCase.loadInitialPage();

        expect(result.items, testItems);
        expect(result.currentPage, 1);
        expect(result.hasMore, isFalse);
        expect(result.isLoadingMore, isFalse);
      });
    });

    group('loadNextPage', () {
      test('loads next page and combines with current items', () async {
        const initialItems = [
          QiitaItem(title: 'Article 1', likesCount: 10, userId: 'user1'),
        ];
        const newItems = [
          QiitaItem(title: 'Article 2', likesCount: 5, userId: 'user2'),
        ];

        final currentPage = QiitaItemsPage(
          items: initialItems,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );

        when(mockRepository.fetchItems(page: 2, perPage: 20))
            .thenAnswer((_) async => newItems);

        final result = await useCase.loadNextPage(currentPage);

        expect(result.items, [...initialItems, ...newItems]);
        expect(result.currentPage, 2);
        expect(result.hasMore, isFalse); // newItems.length < 20
        expect(result.isLoadingMore, isFalse);
      });

      test('returns same page when hasMore is false', () async {
        final currentPage = QiitaItemsPage(
          items: const [QiitaItem(title: 'Article 1', likesCount: 10, userId: 'user1')],
          currentPage: 1,
          hasMore: false,
          isLoadingMore: false,
        );

        final result = await useCase.loadNextPage(currentPage);

        expect(result, currentPage);
        verifyNever(mockRepository.fetchItems(page: anyNamed('page'), perPage: anyNamed('perPage')));
      });
    });
  });
}