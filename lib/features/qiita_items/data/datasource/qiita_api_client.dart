import 'package:dio/dio.dart';
import '../model/qiita_item_model.dart';

abstract interface class QiitaApiClient {
  Future<List<QiitaItemModel>> fetchItems({
    int page,
    int perPage,
  });
}

class QiitaApiClientImpl implements QiitaApiClient {
  QiitaApiClientImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<QiitaItemModel>> fetchItems({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v2/items',
      queryParameters: {'page': page, 'per_page': perPage},
    );

    return (response.data ?? [])
        .map((json) => QiitaItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}