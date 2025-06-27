import 'package:flutter_test/flutter_test.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_items_page.dart';

void main() {
  group('QiitaItemsPage', () {
    const testItems = [
      QiitaItem(title: 'Test Article 1', likesCount: 10, userId: 'user1'),
      QiitaItem(title: 'Test Article 2', likesCount: 5, userId: 'user2'),
    ];

    test('constructor creates instance with all properties', () {
      const page = QiitaItemsPage(
        items: testItems,
        currentPage: 2,
        hasMore: true,
        isLoadingMore: true,
      );

      expect(page.items, testItems);
      expect(page.currentPage, 2);
      expect(page.hasMore, isTrue);
      expect(page.isLoadingMore, isTrue);
    });

    test('constructor uses default value for isLoadingMore', () {
      const page = QiitaItemsPage(
        items: testItems,
        currentPage: 1,
        hasMore: false,
      );

      expect(page.isLoadingMore, isFalse); // デフォルト値
    });

    test('empty static constant has correct values', () {
      expect(QiitaItemsPage.empty.items, isEmpty);
      expect(QiitaItemsPage.empty.currentPage, 0);
      expect(QiitaItemsPage.empty.hasMore, isTrue);
      expect(QiitaItemsPage.empty.isLoadingMore, isFalse);
    });

    group('copyWith', () {
      late QiitaItemsPage originalPage;

      setUp(() {
        originalPage = const QiitaItemsPage(
          items: testItems,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );
      });

      test('copies all properties when all parameters are provided', () {
        const newItems = [
          QiitaItem(title: 'New Article', likesCount: 15, userId: 'user3'),
        ];

        final copiedPage = originalPage.copyWith(
          items: newItems,
          currentPage: 3,
          hasMore: false,
          isLoadingMore: true,
        );

        expect(copiedPage.items, newItems);
        expect(copiedPage.currentPage, 3);
        expect(copiedPage.hasMore, isFalse);
        expect(copiedPage.isLoadingMore, isTrue);
      });

      test('preserves original items when items parameter is null', () {
        final copiedPage = originalPage.copyWith(
          currentPage: 2,
        );

        expect(copiedPage.items, testItems); // 元の値を保持
        expect(copiedPage.currentPage, 2);
      });

      test('preserves original currentPage when currentPage parameter is null', () {
        final copiedPage = originalPage.copyWith(
          hasMore: false,
        );

        expect(copiedPage.currentPage, 1); // 元の値を保持
        expect(copiedPage.hasMore, isFalse);
      });

      test('preserves original hasMore when hasMore parameter is null', () {
        final copiedPage = originalPage.copyWith(
          items: [],
        );

        expect(copiedPage.hasMore, isTrue); // 元の値を保持
        expect(copiedPage.items, isEmpty);
      });

      test('preserves original isLoadingMore when isLoadingMore parameter is null', () {
        // これがカバレッジ100%にするために必要なテスト
        final copiedPage = originalPage.copyWith(
          currentPage: 2,
          hasMore: false,
          // isLoadingMoreはnullで渡さない
        );

        expect(copiedPage.isLoadingMore, isFalse); // 元の値を保持
        expect(copiedPage.currentPage, 2);
        expect(copiedPage.hasMore, isFalse);
      });

      test('can explicitly set isLoadingMore to false', () {
        const pageWithLoadingTrue = QiitaItemsPage(
          items: testItems,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: true,
        );

        final copiedPage = pageWithLoadingTrue.copyWith(
          isLoadingMore: false,
        );

        expect(copiedPage.isLoadingMore, isFalse);
        expect(copiedPage.items, testItems);
        expect(copiedPage.currentPage, 1);
        expect(copiedPage.hasMore, isTrue);
      });

      test('can explicitly set isLoadingMore to true', () {
        final copiedPage = originalPage.copyWith(
          isLoadingMore: true,
        );

        expect(copiedPage.isLoadingMore, isTrue);
        expect(copiedPage.items, testItems);
        expect(copiedPage.currentPage, 1);
        expect(copiedPage.hasMore, isTrue);
      });

      test('creates new instance when no parameters are provided', () {
        final copiedPage = originalPage.copyWith();

        expect(copiedPage.items, originalPage.items);
        expect(copiedPage.currentPage, originalPage.currentPage);
        expect(copiedPage.hasMore, originalPage.hasMore);
        expect(copiedPage.isLoadingMore, originalPage.isLoadingMore);
        
        // 異なるインスタンスであることを確認
        expect(identical(copiedPage, originalPage), isFalse);
      });
    });
  });
}