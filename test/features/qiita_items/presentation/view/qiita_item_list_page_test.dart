import 'dart:async';
import 'package:flutter/cupertino.dart';
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

    group('_buildNavigationBar', () {
      testWidgets('displays navigation bar with correct title', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationLoadingNotifier()),
            ],
            child: const CupertinoApp(home: QiitaItemListPage()),
          ),
        );

        // CupertinoNavigationBarが存在することを確認
        final navBarFinder = find.byType(CupertinoNavigationBar);
        expect(navBarFinder, findsOneWidget);

        // タイトルテキストが正しく表示されることを確認
        expect(find.text('Qiita 記事一覧'), findsOneWidget);

      });
    });

    group('_buildLoadingView', () {
      testWidgets('displays centered CupertinoActivityIndicator', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationLoadingNotifier()),
            ],
            child: const CupertinoApp(home: QiitaItemListPage()),
          ),
        );

        // 中央に配置されたローディングインジケーターを確認
        final centerFinder = find.byWidgetPredicate(
          (widget) => widget is Center && widget.child is CupertinoActivityIndicator,
        );
        expect(centerFinder, findsOneWidget);

        // CupertinoActivityIndicatorが存在することを確認
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      });
    });

    group('_buildErrorView', () {
      testWidgets('displays error layout with all required elements', (tester) async {
        const errorMessage = 'Network error';

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationErrorNotifier(errorMessage)),
            ],
            child: const CupertinoApp(home: QiitaItemListPage()),
          ),
        );

        await tester.pumpAndSettle();

        // エラーアイコンが表示されることを確認
        expect(find.byIcon(CupertinoIcons.exclamationmark_triangle), findsOneWidget);

        // エラーメッセージテキストが表示されることを確認
        expect(find.text('エラーが発生しました'), findsOneWidget);
        expect(find.text('Exception: $errorMessage'), findsOneWidget);

        // 再試行ボタンが表示されることを確認
        expect(find.text('再試行'), findsOneWidget);
        expect(find.byType(CupertinoButton), findsOneWidget);

        // レイアウト構造の確認（Center > Padding > Column）
        final centerWidget = find.byWidgetPredicate(
          (widget) => widget is Center &&
                      widget.child is Padding &&
                      (widget.child as Padding).child is Column,
        );
        expect(centerWidget, findsOneWidget);
      });

      testWidgets('retry button triggers refresh action', (tester) async {
        const errorMessage = 'Network error';
        final errorNotifier = TestPaginationErrorNotifier(errorMessage);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              qiitaItemsPaginationNotifierProvider.overrideWith(() => errorNotifier),
            ],
            child: const CupertinoApp(home: QiitaItemListPage()),
          ),
        );

        await tester.pumpAndSettle();

        // 初期状態でrefreshが呼ばれていないことを確認
        expect(errorNotifier.refreshCallCount, 0);

        // 再試行ボタンをタップ
        await tester.tap(find.text('再試行'));
        await tester.pumpAndSettle();

        // refreshが呼ばれたことを確認
        expect(errorNotifier.refreshCallCount, 1);
      });
    });

    group('_buildDataView', () {
      testWidgets('displays CustomScrollView with CupertinoSliverRefreshControl and SliverList', (tester) async {
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
            child: const CupertinoApp(home: QiitaItemListPage()),
          ),
        );

        await tester.pumpAndSettle();

        // CustomScrollViewが存在することを確認
        expect(find.byType(CustomScrollView), findsOneWidget);

        // CustomScrollViewの構成を確認
        final customScrollView = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
        expect(customScrollView.physics, isA<BouncingScrollPhysics>());
        expect(customScrollView.slivers, hasLength(2));

        // 最初のSliverがCupertinoSliverRefreshControlであることを確認
        expect(customScrollView.slivers.first, isA<CupertinoSliverRefreshControl>());

        // 2番目のSliverがSliverListであることを確認
        expect(customScrollView.slivers[1], isA<SliverList>());

        // SliverListのdelegateがSliverChildBuilderDelegateであることを確認
        final sliverList = customScrollView.slivers[1] as SliverList;
        expect(sliverList.delegate, isA<SliverChildBuilderDelegate>());

        // _buildListItemが使用されていることを間接的に確認（CupertinoListTileが表示される）
        expect(find.byType(CupertinoListTile), findsNWidgets(2));
      });

      testWidgets('CupertinoSliverRefreshControl onRefresh callback triggers refresh', (tester) async {
        final testPage = QiitaItemsPage(
          items: testItems,
          currentPage: 1,
          hasMore: false,
          isLoadingMore: false,
        );

        final refreshableNotifier = TestPaginationRefreshableNotifier(testPage);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              qiitaItemsPaginationNotifierProvider.overrideWith(() => refreshableNotifier),
            ],
            child: const CupertinoApp(home: QiitaItemListPage()),
          ),
        );

        await tester.pumpAndSettle();

        // 初期状態でrefreshが呼ばれていないことを確認
        expect(refreshableNotifier.refreshCallCount, 0);

        // CupertinoSliverRefreshControlのonRefreshコールバックを直接実行
        final customScrollView = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
        final refreshControl = customScrollView.slivers.first as CupertinoSliverRefreshControl;
        expect(refreshControl.onRefresh, isNotNull);

        // onRefreshコールバックを実行
        await refreshControl.onRefresh!();

        // refreshが呼ばれたことを確認
        expect(refreshableNotifier.refreshCallCount, 1);
      });
    });

    group('_buildListItem', () {
      group('normal item display', () {
        testWidgets('displays CupertinoListTile with correct content', (tester) async {
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
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          await tester.pumpAndSettle();

          // CupertinoListTileが正しい数表示されることを確認
          expect(find.byType(CupertinoListTile), findsNWidgets(2));

          // アイテムのタイトルが表示されることを確認
          expect(find.text('Test Article 1'), findsOneWidget);
          expect(find.text('Test Article 2'), findsOneWidget);

          // アイテムのサブタイトルが表示されることを確認
          expect(find.text('♥ 10 by user1'), findsOneWidget);
          expect(find.text('♥ 5 by user2'), findsOneWidget);

          // シェブロンが表示されることを確認
          expect(find.byType(CupertinoListTileChevron), findsNWidgets(2));
        });

        testWidgets('displays separator between items', (tester) async {
          const separatorTestItems = [
            QiitaItem(title: 'Article 1', likesCount: 1, userId: 'user1'),
            QiitaItem(title: 'Article 2', likesCount: 2, userId: 'user2'),
            QiitaItem(title: 'Article 3', likesCount: 3, userId: 'user3'),
          ];

          final testPage = QiitaItemsPage(
            items: separatorTestItems,
            currentPage: 1,
            hasMore: false,
            isLoadingMore: false,
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(testPage)),
              ],
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          await tester.pumpAndSettle();

          // 3つのアイテムが表示されている
          expect(find.byType(CupertinoListTile), findsNWidgets(3));

          // セパレータ用のContainerが存在することを確認
          expect(find.byType(Container), findsWidgets);
        });
      });

      group('infinite scroll trigger', () {
        testWidgets('triggers loadMore when reaching 3rd-to-last item', (tester) async {
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
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          // 初期状態でloadMoreが呼ばれていないことを確認
          expect(loadMoreNotifier.loadMoreCallCount, 0);

          await tester.pump();

          // 初期レンダリング後もloadMoreが呼ばれていないことを確認
          expect(loadMoreNotifier.loadMoreCallCount, 0);

          // 17番目のアイテム（3番目から最後）が表示されるまでスクロール
          final seventeenthItemFinder = find.text('Article 17');
          await tester.scrollUntilVisible(seventeenthItemFinder, 50.0);
          await tester.pumpAndSettle();

          // 3番目検知でloadMoreが呼ばれることを確認
          expect(loadMoreNotifier.loadMoreCallCount, greaterThan(0));
        });

        testWidgets('does not trigger loadMore when hasMore is false', (tester) async {
          final loadMoreNotifier = TestPaginationLoadMoreNotifier(QiitaItemsPage(
            items: List.generate(5, (i) => QiitaItem(
              title: 'Article $i',
              likesCount: i,
              userId: 'user$i',
            )),
            currentPage: 1,
            hasMore: false, // 追加データなし
            isLoadingMore: false,
          ));

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                qiitaItemsPaginationNotifierProvider.overrideWith(() => loadMoreNotifier),
              ],
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          await tester.pumpAndSettle();

          // loadMoreが呼ばれないことを確認
          expect(loadMoreNotifier.loadMoreCallCount, 0);
        });

        testWidgets('does not trigger loadMore when already loading', (tester) async {
          final loadMoreNotifier = TestPaginationLoadMoreNotifier(QiitaItemsPage(
            items: List.generate(5, (i) => QiitaItem(
              title: 'Article $i',
              likesCount: i,
              userId: 'user$i',
            )),
            currentPage: 1,
            hasMore: true,
            isLoadingMore: true, // 既にローディング中
          ));

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                qiitaItemsPaginationNotifierProvider.overrideWith(() => loadMoreNotifier),
              ],
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          await tester.pump();

          // loadMoreが呼ばれないことを確認
          expect(loadMoreNotifier.loadMoreCallCount, 0);
        });
      });

      group('loading more indicator', () {
        testWidgets('displays loading more indicator when isLoadingMore is true', (tester) async {
          final testPage = QiitaItemsPage(
            items: testItems,
            currentPage: 1,
            hasMore: true,
            isLoadingMore: true,
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(testPage)),
              ],
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          await tester.pump();

          // アイテムが表示されている
          expect(find.byType(CupertinoListTile), findsNWidgets(2));

          // 追加読み込み用のインジケーターのレイアウト構造を確認（Padding > Center > CupertinoActivityIndicator）
          final loadingMoreFinder = find.byWidgetPredicate(
            (widget) => widget is Padding &&
                         widget.child is Center &&
                         (widget.child as Center).child is CupertinoActivityIndicator,
          );
          expect(loadingMoreFinder, findsOneWidget);
        });
      });

      group('end message', () {
        testWidgets('displays end message when no more items available', (tester) async {
          final testPage = QiitaItemsPage(
            items: testItems,
            currentPage: 2,
            hasMore: false,
            isLoadingMore: false,
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                qiitaItemsPaginationNotifierProvider.overrideWith(() => TestPaginationDataNotifier(testPage)),
              ],
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          await tester.pumpAndSettle();

          // アイテムが表示されている
          expect(find.byType(CupertinoListTile), findsNWidgets(2));

          // 終了メッセージが表示されることを確認
          expect(find.text('全ての記事を読み込みました'), findsOneWidget);

          // レイアウト構造の確認（Padding > Center > Text）
          final endMessageFinder = find.byWidgetPredicate(
            (widget) => widget is Padding &&
                         widget.child is Center &&
                         (widget.child as Center).child is Text &&
                         ((widget.child as Center).child as Text).data == '全ての記事を読み込みました',
          );
          expect(endMessageFinder, findsOneWidget);
        });
      });

      group('empty list', () {
        testWidgets('displays end message for empty list', (tester) async {
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
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          await tester.pumpAndSettle();
          
          // アイテムが表示されていない
          expect(find.byType(CupertinoListTile), findsNothing);
          
          // 終了メッセージが表示されている
          expect(find.text('全ての記事を読み込みました'), findsOneWidget);
        });
      });

      group('hasMore true with no loading', () {
        testWidgets('displays only items when hasMore is true but not loading', (tester) async {
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
              child: const CupertinoApp(home: QiitaItemListPage()),
            ),
          );

          await tester.pumpAndSettle();
          
          // 2つのアイテムのみ表示
          expect(find.byType(CupertinoListTile), findsNWidgets(2));
          
          // ローディングインジケーターや終了メッセージが表示されないことを確認
          expect(find.byType(CupertinoActivityIndicator), findsNothing);
          expect(find.text('全ての記事を読み込みました'), findsNothing);
        });
      });
    });
  });
}

// テスト用Notifierクラス
class TestPaginationLoadMoreNotifier extends QiitaItemsPaginationNotifier {
  TestPaginationLoadMoreNotifier(this.page);
  final QiitaItemsPage page;
  int loadMoreCallCount = 0;

  @override
  Future<QiitaItemsPage> build() async => page;

  @override
  Future<void> loadMore() async {
    loadMoreCallCount++;
  }
}

class TestPaginationLoadingNotifier extends QiitaItemsPaginationNotifier {
  @override
  Future<QiitaItemsPage> build() async {
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