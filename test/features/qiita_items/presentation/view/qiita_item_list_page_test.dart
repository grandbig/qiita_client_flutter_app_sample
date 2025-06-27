import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
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
            qiitaItemsNotifierProvider.overrideWith(() => TestLoadingNotifier()),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Qiita 記事一覧'), findsOneWidget);
    });

    testWidgets('displays items list when data is loaded', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsNotifierProvider.overrideWith(() => TestDataNotifier(testItems)),
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
            qiitaItemsNotifierProvider.overrideWith(() => TestErrorNotifier(errorMessage)),
          ],
          child: const MaterialApp(home: QiitaItemListPage()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('エラーが発生しました：Exception: $errorMessage'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('calls refresh when pull-to-refresh is triggered', (tester) async {
      final refreshableNotifier = TestRefreshableNotifier(testItems);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiitaItemsNotifierProvider.overrideWith(() => refreshableNotifier),
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
  });
}

class TestLoadingNotifier extends QiitaItemsNotifier {
  @override
  Future<List<QiitaItem>> build() async {
    // AsyncLoading状態を維持するために完了しないFutureを返す
    return Completer<List<QiitaItem>>().future;
  }
}

class TestDataNotifier extends QiitaItemsNotifier {
  TestDataNotifier(this.items);
  final List<QiitaItem> items;

  @override
  Future<List<QiitaItem>> build() async {
    return items;
  }
}

class TestErrorNotifier extends QiitaItemsNotifier {
  TestErrorNotifier(this.errorMessage);
  final String errorMessage;

  @override
  Future<List<QiitaItem>> build() async {
    throw Exception(errorMessage);
  }
}

class TestRefreshableNotifier extends QiitaItemsNotifier {
  TestRefreshableNotifier(this.items);
  final List<QiitaItem> items;
  int refreshCallCount = 0;

  @override
  Future<List<QiitaItem>> build() async {
    return items;
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => items);
  }
}