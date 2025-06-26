import 'package:dio/dio.dart';
import 'package:qiita_client_app/features/qiita_items/data/datasource/qiita_api_client.dart';
import 'package:qiita_client_app/features/qiita_items/domain/usecase/qiita_items_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
import 'package:qiita_client_app/features/qiita_items/domain/repository/qiita_item_repository.dart';
import 'package:qiita_client_app/features/qiita_items/data/repository/qiita_item_repository_impl.dart';

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
QiitaItemsUseCase qiitaItemsUseCase(Ref ref) => QiitaItemsUseCase(ref.watch(qiitaItemRepositoryProvider));

@riverpod
class QiitaItemsNotifier extends _$QiitaItemsNotifier {
  @override
  Future<List<QiitaItem>> build() async {
    return _fetch();
  }

  Future<List<QiitaItem>> _fetch({int page = 1}) async {
    final usecase = ref.read(qiitaItemsUseCaseProvider);
    return usecase(page: page);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}