import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qiita_client_app/features/qiita_items/data/datasource/qiita_api_client.dart';
import 'package:qiita_client_app/features/qiita_items/data/repository/qiita_item_repository_impl.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_items_page.dart';
import 'package:qiita_client_app/features/qiita_items/domain/repository/qiita_item_repository.dart';
import 'package:qiita_client_app/features/qiita_items/domain/usecase/qiita_items_pagination_usecase.dart';
import 'package:qiita_client_app/features/qiita_items/presentation/provider/qiita_items_provider.dart';

// Mockクラスを作成
class MockQiitaItemsPaginationUseCase implements QiitaItemsPaginationUseCase {
  QiitaItemsPage? _mockInitialPage;
  QiitaItemsPage? _mockNextPage;
  int _loadInitialCallCount = 0;
  int _loadNextPageCallCount = 0;
  bool _shouldThrowErrorOnInitial = false;
  bool _shouldThrowErrorOnNext = false;
  String _errorMessage = 'Test error';
  
  void setMockInitialPage(QiitaItemsPage page) {
    _mockInitialPage = page;
  }
  
  void setMockNextPage(QiitaItemsPage page) {
    _mockNextPage = page;
  }
  
  void setShouldThrowErrorOnInitial(bool shouldThrow, [String? errorMessage]) {
    _shouldThrowErrorOnInitial = shouldThrow;
    if (errorMessage != null) _errorMessage = errorMessage;
  }
  
  void setShouldThrowErrorOnNext(bool shouldThrow, [String? errorMessage]) {
    _shouldThrowErrorOnNext = shouldThrow;
    if (errorMessage != null) _errorMessage = errorMessage;
  }
  
  int get loadInitialCallCount => _loadInitialCallCount;
  int get loadNextPageCallCount => _loadNextPageCallCount;
  
  void reset() {
    _loadInitialCallCount = 0;
    _loadNextPageCallCount = 0;
    _shouldThrowErrorOnInitial = false;
    _shouldThrowErrorOnNext = false;
  }
  
  @override
  Future<QiitaItemsPage> loadInitialPage({int perPage = 20}) async {
    _loadInitialCallCount++;
    if (_shouldThrowErrorOnInitial) {
      throw Exception(_errorMessage);
    }
    return _mockInitialPage ?? const QiitaItemsPage(
      items: [],
      currentPage: 1,
      hasMore: false,
      isLoadingMore: false,
    );
  }
  
  @override
  Future<QiitaItemsPage> loadNextPage(QiitaItemsPage currentPage, {int perPage = 20}) async {
    _loadNextPageCallCount++;
    if (_shouldThrowErrorOnNext) {
      throw Exception(_errorMessage);
    }
    return _mockNextPage ?? currentPage;
  }
}

void main() {
  group('QiitaItemsProvider dependency injection tests', () {
    late ProviderContainer container;

    setUp(() {
      // dotenvを初期化（空の環境変数で）
      dotenv.testLoad(fileInput: '');
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('dioProvider creates Dio instance with correct base URL', () {
      final dio = container.read(dioProvider);
      
      expect(dio, isA<Dio>());
      expect(dio.options.baseUrl, 'https://qiita.com');
    });

    test('dioProvider sets Authorization header when token exists', () {
      // 新しいコンテナでトークンありの状態をテスト
      container.dispose();
      dotenv.testLoad(fileInput: 'QIITA_ACCESS_TOKEN=test_token_123');
      container = ProviderContainer();
      
      final dio = container.read(dioProvider);
      
      expect(dio.options.headers['Authorization'], 'Bearer test_token_123');
    });

    test('qiitaApiClientProvider returns QiitaApiClientImpl instance', () {
      final apiClient = container.read(qiitaApiClientProvider);
      
      expect(apiClient, isA<QiitaApiClientImpl>());
      expect(apiClient, isA<QiitaApiClient>());
    });

    test('qiitaItemRepositoryProvider returns QiitaItemRepositoryImpl instance', () {
      final repository = container.read(qiitaItemRepositoryProvider);
      
      expect(repository, isA<QiitaItemRepositoryImpl>());
      expect(repository, isA<QiitaItemRepository>());
    });

    test('qiitaItemsPaginationUseCaseProvider returns QiitaItemsPaginationUseCase instance', () {
      final paginationUseCase = container.read(qiitaItemsPaginationUseCaseProvider);
      
      expect(paginationUseCase, isA<QiitaItemsPaginationUseCase>());
    });
  });

  group('QiitaItemsPaginationNotifier tests', () {
    late ProviderContainer container;
    late MockQiitaItemsPaginationUseCase mockPaginationUseCase;

    setUp(() {
      dotenv.testLoad(fileInput: '');
      mockPaginationUseCase = MockQiitaItemsPaginationUseCase();
      container = ProviderContainer(
        overrides: [
          qiitaItemsPaginationUseCaseProvider.overrideWithValue(mockPaginationUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial build calls loadInitialPage and returns data', () async {
      const testItems = [
        QiitaItem(title: 'Test Article', likesCount: 5, userId: 'user1'),
      ];
      
      final testPage = QiitaItemsPage(
        items: testItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      );
      
      // UseCaseのモックレスポンスを設定
      mockPaginationUseCase.setMockInitialPage(testPage);
      
      // NotifierProviderを読み取って初期buildを実行
      final asyncValue = await container.read(qiitaItemsPaginationNotifierProvider.future);
      
      // 期待する結果の確認
      expect(asyncValue.items, testItems);
      expect(asyncValue.currentPage, 1);
      expect(asyncValue.hasMore, isTrue);
      expect(asyncValue.isLoadingMore, isFalse);
      expect(mockPaginationUseCase.loadInitialCallCount, 1);
    });

    test('loadMore calls loadNextPage and updates state with new items', () async {
      const initialItems = [
        QiitaItem(title: 'Initial Article', likesCount: 3, userId: 'user1'),
      ];
      const combinedItems = [
        QiitaItem(title: 'Initial Article', likesCount: 3, userId: 'user1'),
        QiitaItem(title: 'New Article', likesCount: 8, userId: 'user2'),
      ];
      
      final initialPage = QiitaItemsPage(
        items: initialItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      );
      
      final newPage = QiitaItemsPage(
        items: combinedItems, // 既存 + 新規の結合されたリスト
        currentPage: 2,
        hasMore: false,
        isLoadingMore: false,
      );
      
      // 初期データを設定
      mockPaginationUseCase.setMockInitialPage(initialPage);
      mockPaginationUseCase.setMockNextPage(newPage);
      
      // 初期buildを実行
      await container.read(qiitaItemsPaginationNotifierProvider.future);
      expect(mockPaginationUseCase.loadInitialCallCount, 1);
      
      // loadMoreを実行
      final notifier = container.read(qiitaItemsPaginationNotifierProvider.notifier);
      await notifier.loadMore();
      
      // 結果確認
      final currentState = container.read(qiitaItemsPaginationNotifierProvider);
      expect(currentState.value?.items, combinedItems); // 既存 + 新規
      expect(currentState.value?.currentPage, 2);
      expect(currentState.value?.hasMore, isFalse);
      expect(mockPaginationUseCase.loadNextPageCallCount, 1);
    });

    test('loadMore does nothing when hasMore is false', () async {
      const testItems = [
        QiitaItem(title: 'Test Article', likesCount: 5, userId: 'user1'),
      ];
      
      final testPage = QiitaItemsPage(
        items: testItems,
        currentPage: 2,
        hasMore: false, // もう読み込むページがない
        isLoadingMore: false,
      );
      
      // UseCaseのモックレスポンスを設定
      mockPaginationUseCase.setMockInitialPage(testPage);
      
      // 初期buildを実行
      await container.read(qiitaItemsPaginationNotifierProvider.future);
      mockPaginationUseCase.reset(); // カウンターをリセット
      
      // loadMoreを実行
      final notifier = container.read(qiitaItemsPaginationNotifierProvider.notifier);
      await notifier.loadMore();
      
      // loadNextPageが呼ばれていないことを確認
      expect(mockPaginationUseCase.loadNextPageCallCount, 0);
      
      // 状態が変わっていないことを確認
      final currentState = container.read(qiitaItemsPaginationNotifierProvider);
      expect(currentState.value?.items, testItems);
      expect(currentState.value?.hasMore, isFalse);
    });

    test('loadMore does nothing when already loading more', () async {
      const testItems = [
        QiitaItem(title: 'Test Article', likesCount: 5, userId: 'user1'),
      ];
      
      final testPage = QiitaItemsPage(
        items: testItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: true, // すでにローディング中
      );
      
      // UseCaseのモックレスポンスを設定
      mockPaginationUseCase.setMockInitialPage(testPage);
      
      // 初期buildを実行
      await container.read(qiitaItemsPaginationNotifierProvider.future);
      mockPaginationUseCase.reset(); // カウンターをリセット
      
      // loadMoreを実行
      final notifier = container.read(qiitaItemsPaginationNotifierProvider.notifier);
      await notifier.loadMore();
      
      // loadNextPageが呼ばれていないことを確認
      expect(mockPaginationUseCase.loadNextPageCallCount, 0);
    });

    test('refresh calls loadInitialPage and updates state', () async {
      const initialItems = [
        QiitaItem(title: 'Initial Article', likesCount: 3, userId: 'user1'),
      ];
      const refreshedItems = [
        QiitaItem(title: 'Refreshed Article', likesCount: 8, userId: 'user2'),
      ];
      
      final initialPage = QiitaItemsPage(
        items: initialItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      );
      
      final refreshedPage = QiitaItemsPage(
        items: refreshedItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      );
      
      // 初期データを設定
      mockPaginationUseCase.setMockInitialPage(initialPage);
      
      // 初期buildを実行
      await container.read(qiitaItemsPaginationNotifierProvider.future);
      expect(mockPaginationUseCase.loadInitialCallCount, 1);
      
      // refresh用の新しいデータを設定
      mockPaginationUseCase.setMockInitialPage(refreshedPage);
      mockPaginationUseCase.reset(); // コールカウントリセット
      
      // refreshを実行
      final notifier = container.read(qiitaItemsPaginationNotifierProvider.notifier);
      await notifier.refresh();
      
      // 結果確認
      final currentState = container.read(qiitaItemsPaginationNotifierProvider);
      expect(currentState.value?.items, refreshedItems);
      expect(mockPaginationUseCase.loadInitialCallCount, 1); // refreshで1回呼ばれた
    });

    test('loadMore handles error and resets isLoadingMore flag', () async {
      const initialItems = [
        QiitaItem(title: 'Initial Article', likesCount: 3, userId: 'user1'),
      ];
      
      final initialPage = QiitaItemsPage(
        items: initialItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      );
      
      // 初期データを設定
      mockPaginationUseCase.setMockInitialPage(initialPage);
      
      // 初期buildを実行
      await container.read(qiitaItemsPaginationNotifierProvider.future);
      
      // loadNextPageでエラーを発生させる設定
      mockPaginationUseCase.setShouldThrowErrorOnNext(true, 'LoadMore error');
      
      // loadMoreを実行してエラーをキャッチ
      final notifier = container.read(qiitaItemsPaginationNotifierProvider.notifier);
      
      try {
        await notifier.loadMore();
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
      
      // エラー後の状態を確認
      final currentState = container.read(qiitaItemsPaginationNotifierProvider);
      
      // isLoadingMoreがfalseにリセットされていることを確認
      expect(currentState.value?.isLoadingMore, isFalse);
      expect(currentState.value?.items, initialItems); // 元のアイテムは保持
      expect(mockPaginationUseCase.loadNextPageCallCount, 1);
    });

    test('loadMore handles null current state gracefully', () async {
      // 初期buildが完了していない状態でloadMoreを呼び出す
      final notifier = container.read(qiitaItemsPaginationNotifierProvider.notifier);
      
      // loadMoreを実行（state.valueがnullの状態）
      await notifier.loadMore();
      
      // エラーが発生せず、UseCaseも呼ばれないことを確認
      expect(mockPaginationUseCase.loadNextPageCallCount, 0);
    });

    test('initial build handles error during loadInitialPage', () async {
      // loadInitialPageでエラーを発生させる設定
      mockPaginationUseCase.setShouldThrowErrorOnInitial(true, 'Initial load error');
      
      // 初期buildを実行してエラーが発生することを確認
      try {
        await container.read(qiitaItemsPaginationNotifierProvider.future);
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e.toString(), contains('Initial load error'));
      }
      
      // AsyncErrorの状態になることを確認
      final asyncValue = container.read(qiitaItemsPaginationNotifierProvider);
      expect(asyncValue.hasError, isTrue);
      expect(mockPaginationUseCase.loadInitialCallCount, 1);
    });

    test('refresh handles error during reload', () async {
      const initialItems = [
        QiitaItem(title: 'Initial Article', likesCount: 3, userId: 'user1'),
      ];
      
      final initialPage = QiitaItemsPage(
        items: initialItems,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      );
      
      // 正常な初期データを設定
      mockPaginationUseCase.setMockInitialPage(initialPage);
      
      // 初期buildを実行
      await container.read(qiitaItemsPaginationNotifierProvider.future);
      expect(mockPaginationUseCase.loadInitialCallCount, 1);
      
      // refresh時にエラーが発生するように設定
      mockPaginationUseCase.setShouldThrowErrorOnInitial(true, 'Refresh error');
      
      // refreshを実行
      final notifier = container.read(qiitaItemsPaginationNotifierProvider.notifier);
      await notifier.refresh();
      
      // エラー状態になることを確認
      final currentState = container.read(qiitaItemsPaginationNotifierProvider);
      currentState.when(
        data: (data) => fail('Should not be in data state after error'),
        error: (error, stackTrace) {
          expect(error.toString(), contains('Refresh error'));
        },
        loading: () => fail('Should not be in loading state'),
      );
      
      expect(mockPaginationUseCase.loadInitialCallCount, 2); // 初期 + refresh
    });

    test('loadMore does nothing when state value is null without initial build', () async {
      // 新しいコンテナを作成（初期buildを実行しない）
      final freshContainer = ProviderContainer(
        overrides: [
          qiitaItemsPaginationUseCaseProvider.overrideWithValue(mockPaginationUseCase),
        ],
      );
      
      try {
        final notifier = freshContainer.read(qiitaItemsPaginationNotifierProvider.notifier);
        
        // loadMoreを実行（初期buildが完了していない状態）
        await notifier.loadMore();
        
        // UseCaseが呼ばれないことを確認
        expect(mockPaginationUseCase.loadNextPageCallCount, 0);
      } finally {
        freshContainer.dispose();
      }
    });
  });
}