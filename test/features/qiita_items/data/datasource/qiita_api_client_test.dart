import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qiita_client_app/features/qiita_items/data/datasource/qiita_api_client.dart';

import 'qiita_api_client_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('QiitaApiClientImpl', () {
    late MockDio mockDio;
    late QiitaApiClientImpl apiClient;

    setUp(() {
      mockDio = MockDio();
      apiClient = QiitaApiClientImpl(mockDio);
    });

    test('fetchItems returns list of QiitaItemModel', () async {
      const responseData = [
        {
          'title': 'Test Article 1',
          'likes_count': 42,
          'user': {'id': 'user1'},
        },
        {
          'title': 'Test Article 2',
          'likes_count': 100,
          'user': {'id': 'user2'},
        },
      ];

      when(mockDio.get<List<dynamic>>(
        '/api/v2/items',
        queryParameters: {'page': 1, 'per_page': 20},
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v2/items'),
          ));

      final result = await apiClient.fetchItems();

      expect(result, hasLength(2));
      expect(result[0].title, equals('Test Article 1'));
      expect(result[0].likesCount, equals(42));
      expect(result[0].user.id, equals('user1'));
      expect(result[1].title, equals('Test Article 2'));
      expect(result[1].likesCount, equals(100));
      expect(result[1].user.id, equals('user2'));
    });


    test('fetchItems handles null response data', () async {
      when(mockDio.get<List<dynamic>>(
        '/api/v2/items',
        queryParameters: {'page': 1, 'per_page': 20},
      )).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v2/items'),
          ));

      final result = await apiClient.fetchItems();

      expect(result, isEmpty);
    });
  });
}