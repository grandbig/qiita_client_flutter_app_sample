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

      // 初期読み込み用のCircularProgressIndicatorが中央に表示されることを確認
      final centerFinder = find.byWidgetPredicate(
        (widget) => widget is Center && widget.child is CircularProgressIndicator,
      );
      expect(centerFinder, findsOneWidget);
      
      // AppBarのタイトルが正しく表示されることを確認
      final appBarFinder = find.byWidgetPredicate(
        (widget) => widget is AppBar,
      );
      expect(appBarFinder, findsOneWidget);
      
      final appBar = tester.widget<AppBar>(appBarFinder);
      expect((appBar.title as Text).data, 'Qiita 記事一覧');
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
      
      // エラー画面の特定の構造を検証（Center > Column > [Text, SizedBox, ElevatedButton]）
      final errorCenterFinder = find.byWidgetPredicate(
        (widget) => widget is Center &&
                     widget.child is Column &&
                     (widget.child as Column).mainAxisAlignment == MainAxisAlignment.center,
      );
      expect(errorCenterFinder, findsOneWidget);
      
      // Columnの中身を詳細に検証
      final centerWidget = tester.widget<Center>(errorCenterFinder);
      final columnWidget = centerWidget.child as Column;
      expect(columnWidget.children, hasLength(3));
      
      // 1番目: エラーメッセージのText
      expect(columnWidget.children[0], isA<Text>());
      final errorText = columnWidget.children[0] as Text;
      expect(errorText.data, 'エラーが発生しました：Exception: $errorMessage');
      
      // 2番目: SizedBox（間隔用）
      expect(columnWidget.children[1], isA<SizedBox>());
      
      // 3番目: 再試行ボタン
      expect(columnWidget.children[2], isA<ElevatedButton>());
      final elevatedButton = columnWidget.children[2] as ElevatedButton;
      expect((elevatedButton.child as Text).data, '再試行');
      
      // エラー状態ではListViewは表示されない
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(RefreshIndicator), findsNothing);
      expect(find.byType(ListTile), findsNothing);
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
      
      // 追加読み込み用のCircularProgressIndicator（Paddingでラップされている）が表示されている
      final loadingMoreFinder = find.byWidgetPredicate(
        (widget) => widget is Padding && 
                     widget.child is Center &&
                     (widget.child as Center).child is CircularProgressIndicator,
      );
      expect(loadingMoreFinder, findsOneWidget);
      
      // CircularProgressIndicatorは追加読み込み用のみが存在することを確認（合計1個）
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
      
      // 終了メッセージが特定の構造で表示されている（Paddingでラップされている）
      final endMessageFinder = find.byWidgetPredicate(
        (widget) => widget is Padding && 
                     widget.child is Center &&
                     (widget.child as Center).child is Text &&
                     ((widget.child as Center).child as Text).data == '全ての記事を読み込みました',
      );
      expect(endMessageFinder, findsOneWidget);
      
      // Textのスタイルも確認（重要な視覚的特徴のみ）
      final textWidget = tester.widget<Text>(find.text('全ての記事を読み込みました'));
      expect(textWidget.style?.color, Colors.grey); // グレー色は重要なUX要素
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
        items: List.generate(30, (i) => QiitaItem(
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
      
      // スクロール可能領域を取得
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      final maxScrollExtent = scrollable.position.maxScrollExtent;
      
      // 89%の位置までスクロール（90%未満）
      final scrollTo89Percent = maxScrollExtent * 0.89;
      await tester.drag(find.byType(ListView), Offset(0, -scrollTo89Percent));
      await tester.pump();
      
      // 89%では loadMoreが呼ばれていないことを確認
      expect(loadMoreNotifier.loadMoreCallCount, 0);
      
      // 90%の位置までスクロール（90%ちょうど）
      final additionalScroll = maxScrollExtent * 0.01; // 89% + 1% = 90%
      await tester.drag(find.byType(ListView), Offset(0, -additionalScroll));
      await tester.pump();
      
      // 90%でloadMoreが呼ばれることを確認
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
      expect(find.byType(Divider), findsNWidgets(2));
      
      // 最後のListTileの直後にDividerがないことを具体的に検証
      // ListTileを取得
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsNWidgets(3));
      
      // 各ListTileの位置を確認し、最後のListTileの後にDividerがないことを検証
      final lastListTileRect = tester.getRect(listTiles.last);
      
      // 最後のListTileより下の位置にあるDividerがないことを確認
      final dividersAfterLastItem = find.byWidgetPredicate((widget) {
        if (widget is! Divider) return false;
        try {
          final dividerRect = tester.getRect(find.byWidget(widget));
          return dividerRect.top > lastListTileRect.bottom;
        } catch (_) {
          return false;
        }
      });
      expect(dividersAfterLastItem, findsNothing);
      
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