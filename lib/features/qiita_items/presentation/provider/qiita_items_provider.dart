import 'package:dio/dio.dart';
import 'package:qiita_client_app/features/qiita_items/data/datasource/qiita_api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_items_page.dart';
import 'package:qiita_client_app/features/qiita_items/domain/repository/qiita_item_repository.dart';
import 'package:qiita_client_app/features/qiita_items/data/repository/qiita_item_repository_impl.dart';
import 'package:qiita_client_app/features/qiita_items/domain/usecase/qiita_items_pagination_usecase.dart';

part 'qiita_items_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://qiita.com'));
  final String? token = dotenv.env['QIITA_ACCESS_TOKEN'];
  if (token != null) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
  return dio;
}

@riverpod
QiitaApiClient qiitaApiClient(Ref ref) => QiitaApiClientImpl(ref.watch(dioProvider));

@riverpod
QiitaItemRepository qiitaItemRepository(Ref ref) => QiitaItemRepositoryImpl(ref.watch(qiitaApiClientProvider));

@riverpod
QiitaItemsPaginationUseCase qiitaItemsPaginationUseCase(Ref ref) => QiitaItemsPaginationUseCase(ref.watch(qiitaItemRepositoryProvider));

@riverpod
class QiitaItemsPaginationNotifier extends _$QiitaItemsPaginationNotifier {
  @override
  Future<QiitaItemsPage> build() async {
    final useCase = ref.read(qiitaItemsPaginationUseCaseProvider);
    return useCase.loadInitialPage();
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    // ローディング状態を設定
    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final useCase = ref.read(qiitaItemsPaginationUseCaseProvider);
      final newPage = await useCase.loadNextPage(currentState);
      state = AsyncData(newPage);
    } catch (error, _) {
      // エラー時はローディング状態を解除
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
      // エラーを再スロー（必要に応じてエラー処理を追加）
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(qiitaItemsPaginationUseCaseProvider);
      return useCase.loadInitialPage();
    });
  }
}