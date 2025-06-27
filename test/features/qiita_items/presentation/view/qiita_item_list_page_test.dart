import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_items_page.dart';
import 'package:qiita_client_app/features/qiita_items/presentation/provider/qiita_items_provider.dart';
import 'package:qiita_client_app/features/qiita_items/presentation/view/qiita_item_list_page.dart';

void main() {
  group('QiitaItemListPage', () {
    const testItems = [
      QiitaItem(
        title: 'Test Article 1',
        likesCount: 10,
        userId: 'user1',
      ),
      QiitaItem(
        title: 'Test Article 2',
        likesCount: 5,
        userId: 'user2',
      ),
    ];

    testWidgets('displays loading indicator when state is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationLoadingNotifier()),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Qiita 記事一覧'), findsOneWidget);
    });

    testWidgets('displays items list when data is loaded', (tester) async {
      final testPage = QiitaItemsPage(
        items: testItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(testPage)),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      
      // ListViewの中にListTileが正しい順序で表示されているかテスト
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(listTiles, hasLength(2));
      
      // 1つ目のListTileの内容を確認
      final firstTile = listTiles.elementAt(0);
      expect((firstTile.title as Text).data, 'Test Article 1');
      expect((firstTile.subtitle as Text).data, '♥ 10 by user1');
      
      // 2つ目のListTileの内容を確認
      final secondTile = listTiles.elementAt(1);
      expect((secondTile.title as Text).data, 'Test Article 2');
      expect((secondTile.subtitle as Text).data, '♥ 5 by user2');
      
      // RefreshIndicatorが存在することを確認
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays error message when error occurs', (tester) async {
      const errorMessage = 'Network error';
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationErrorNotifier(errorMessage)),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('エラーが発生しました：Exception: $errorMessage'), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays loading more indicator when loading more items', (tester) async {
      final testPage = QiitaItemsPage(
        items: testItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: true, // ローディング中
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(testPage)),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pump();
      
      // アイテムが表示されている
      expect(find.byType(ListTile), findsNWidgets(2));
      
      // ローディングインジケーターも表示されている
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays end message when no more items', (tester) async {
      final testPage = QiitaItemsPage(
        items: testItems,
        currentPage: 2,
        hasMore: false, // 最後のページ
        isLoadingMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(testPage)),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      
      // アイテムが表示されている
      expect(find.byType(ListTile), findsNWidgets(2));
      
      // 終了メッセージが表示されている
      expect(find.text('全ての記事を読み込みました'), findsOneWidget);
    });

    testWidgets('calls refresh when pull-to-refresh is triggered', (tester) async {
      final refreshableNotifier = TestPaginationRefreshableNotifier(QiitaItemsPage(
        items: testItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      ));
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => refreshableNotifier),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      
      // 初期状態でrefreshが呼ばれていないことを確認
      expect(refreshableNotifier.refreshCallCount, 0);
      
      // RefreshIndicatorをflingして引っ張る動作をシミュレート
      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      // refresh()が呼ばれたことを確認
      expect(refreshableNotifier.refreshCallCount, 1);
    });

    testWidgets('triggers loadMore when scrolling past 90%', (tester) async {
      final loadMoreNotifier = TestPaginationLoadMoreNotifier(QiitaItemsPage(
        items: List.generate(20, (i) => QiitaItem(
          title: 'Article $i',
          likesCount: i,
          userId: 'user$i',
        )),
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      ));
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => loadMoreNotifier),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      
      // 初期状態でloadMoreが呼ばれていないことを確認
      expect(loadMoreNotifier.loadMoreCallCount, 0);
      
      // 90%以上スクロールしてloadMoreをトリガー
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      
      // loadMoreが呼ばれたことを確認
      expect(loadMoreNotifier.loadMoreCallCount, greaterThan(0));
    });

    testWidgets('retry button calls refresh on error', (tester) async {
      const errorMessage = 'Network error';
      final errorNotifier = TestPaginationErrorNotifier(errorMessage);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => errorNotifier),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      
      // エラー状態が表示されることを確認
      expect(find.text('エラーが発生しました：Exception: $errorMessage'), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);
      
      // 初期状態でrefreshが呼ばれていないことを確認
      expect(errorNotifier.refreshCallCount, 0);
      
      // 再試行ボタンをタップ
      await tester.tap(find.text('再試行'));
      await tester.pumpAndSettle();
      
      // refreshが呼ばれたことを確認
      expect(errorNotifier.refreshCallCount, 1);
    });

    testWidgets('displays empty list correctly', (tester) async {
      final emptyPage = QiitaItemsPage(
        items: const [],
        currentPage: 1,
        hasMore: false,
        isLoadingMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(emptyPage)),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      
      // アイテムが表示されていない
      expect(find.byType(ListTile), findsNothing);
      
      // 終了メッセージが表示されている
      expect(find.text('全ての記事を読み込みました'), findsOneWidget);
    });

    testWidgets('separator logic works correctly with multiple items', (tester) async {
      const testItems = [
        QiitaItem(title: 'Article 1', likesCount: 1, userId: 'user1'),
        QiitaItem(title: 'Article 2', likesCount: 2, userId: 'user2'),
        QiitaItem(title: 'Article 3', likesCount: 3, userId: 'user3'),
      ];

      final testPage = QiitaItemsPage(
        items: testItems,
        currentPage: 1,
        hasMore: false,
        isLoadingMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(testPage)),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      
      // 3つのアイテムが表示されている
      expect(find.byType(ListTile), findsNWidgets(3));
      
      // 2つのDivider（アイテム間のセパレータ）が表示されている
      // 最後のアイテムの後にはセパレータはない
      expect(find.byType(Divider), findsNWidgets(2));
      
      // 終了メッセージも表示されている
      expect(find.text('全ての記事を読み込みました'), findsOneWidget);
    });

    testWidgets('displays correct item count when hasMore is true with no loading', (tester) async {
      const testItems = [
        QiitaItem(title: 'Article 1', likesCount: 1, userId: 'user1'),
        QiitaItem(title: 'Article 2', likesCount: 2, userId: 'user2'),
      ];

      final testPage = QiitaItemsPage(
        items: testItems,
        currentPage: 1,
        hasMore: true, // まだページがある
        isLoadingMore: false, // ローディング中ではない
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(testPage)),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      
      // 2つのアイテムのみ表示（ローディングや終了メッセージなし）
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('全ての記事を読み込みました'), findsNothing);
    });
  });
}

// 追加のテスト用Notifierクラス
class TestPaginationLoadMoreNotifier extends QiitaItemsPaginationNotifier {
  TestPaginationLoadMoreNotifier(this.page);
  final QiitaItemsPage page;
  int loadMoreCallCount = 0;

  @override
  Future<QiitaItemsPage> build() async => page;

  @override
  Future<void> loadMore() async {
    loadMoreCallCount++;
    // テスト用のシンプルなloadMore実装（providerの依存関係を避ける）
  }
}

class TestPaginationLoadingNotifier extends QiitaItemsPaginationNotifier {
  @override
  Future<QiitaItemsPage> build() async {
    // AsyncLoading状態を維持するために完了しないFutureを返す
    return Completer<QiitaItemsPage>().future;
  }
}

class TestPaginationDataNotifier extends QiitaItemsPaginationNotifier {
  TestPaginationDataNotifier(this.page);
  final QiitaItemsPage page;

  @override
  Future<QiitaItemsPage> build() async {
    return page;
  }
}

class TestPaginationErrorNotifier extends QiitaItemsPaginationNotifier {
  TestPaginationErrorNotifier(this.errorMessage);
  final String errorMessage;
  int refreshCallCount = 0;

  @override
  Future<QiitaItemsPage> build() async {
    throw Exception(errorMessage);
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
    state = const AsyncLoading();
    // エラーを維持
    state = AsyncError(Exception(errorMessage), StackTrace.current);
  }
}

class TestPaginationRefreshableNotifier extends QiitaItemsPaginationNotifier {
  TestPaginationRefreshableNotifier(this.page);
  final QiitaItemsPage page;
  int refreshCallCount = 0;

  @override
  Future<QiitaItemsPage> build() async {
    return page;
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => page);
  }
}