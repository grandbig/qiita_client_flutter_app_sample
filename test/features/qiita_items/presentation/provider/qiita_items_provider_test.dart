import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qiita_client_app/features/qiita_items/data/datasource/qiita_api_client.dart';
import 'package:qiita_client_app/features/qiita_items/data/repository/qiita_item_repository_impl.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
import 'package:qiita_client_app/features/qiita_items/domain/repository/qiita_item_repository.dart';
import 'package:qiita_client_app/features/qiita_items/domain/usecase/qiita_items_usecase.dart';
import 'package:qiita_client_app/features/qiita_items/presentation/provider/qiita_items_provider.dart';

// Mockクラスを作成
class MockQiitaItemsUseCase implements QiitaItemsUseCase {
  List<QiitaItem>? _mockResponse;
  int _callCount = 0;
  
  void setMockResponse(List<QiitaItem> response) {
    _mockResponse = response;
  }
  
  bool get wasCalled => _callCount > 0;
  int get callCount => _callCount;
  
  void reset() {
    _callCount = 0;
  }
  
  @override
  Future<List<QiitaItem>> call({int page = 1, int perPage = 20}) async {
    _callCount++;
    return _mockResponse ?? [];
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

    test('qiitaItemsUseCaseProvider returns QiitaItemsUseCase instance', () {
      final useCase = container.read(qiitaItemsUseCaseProvider);
      
      expect(useCase, isA<QiitaItemsUseCase>());
    });
  });

  group('QiitaItemsNotifier tests', () {
    late ProviderContainer container;
    late MockQiitaItemsUseCase mockUseCase;

    setUp(() {
      dotenv.testLoad(fileInput: '');
      mockUseCase = MockQiitaItemsUseCase();
      container = ProviderContainer(
        overrides: [
          qiitaItemsUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial build calls useCase and returns data', () async {
      const testItems = [
        QiitaItem(title: 'Test Article', likesCount: 5, userId: 'user1'),
      ];
      
      // UseCaseのモックレスポンスを設定
      mockUseCase.setMockResponse(testItems);
      
      // NotifierProviderを読み取って初期buildを実行
      final asyncValue = await container.read(qiitaItemsNotifierProvider.future);
      
      // 期待する結果の確認
      expect(asyncValue, testItems);
      expect(mockUseCase.wasCalled, isTrue);
    });

    test('refresh calls useCase and updates state', () async {
      const initialItems = [
        QiitaItem(title: 'Initial Article', likesCount: 3, userId: 'user1'),
      ];
      const refreshedItems = [
        QiitaItem(title: 'Refreshed Article', likesCount: 8, userId: 'user2'),
      ];
      
      // 初期データを設定
      mockUseCase.setMockResponse(initialItems);
      
      // 初期buildを実行
      await container.read(qiitaItemsNotifierProvider.future);
      expect(mockUseCase.callCount, 1);
      
      // refresh用の新しいデータを設定
      mockUseCase.setMockResponse(refreshedItems);
      mockUseCase.reset(); // コールカウントリセット
      
      // refreshを実行
      final notifier = container.read(qiitaItemsNotifierProvider.notifier);
      await notifier.refresh();
      
      // 結果確認
      final currentState = container.read(qiitaItemsNotifierProvider);
      expect(currentState.value, refreshedItems);
      expect(mockUseCase.callCount, 1); // refreshで1回呼ばれた
    });
  });
}