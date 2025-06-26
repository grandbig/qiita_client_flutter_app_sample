import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qiita_client_app/features/qiita_items/data/datasource/qiita_api_client.dart';
import 'package:qiita_client_app/features/qiita_items/data/model/qiita_item_model.dart';
import 'package:qiita_client_app/features/qiita_items/data/repository/qiita_item_repository_impl.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';

import 'qiita_item_repository_impl_test.mocks.dart';

@GenerateMocks([QiitaApiClient])
void main() {
  group('QiitaItemRepositoryImpl', () {
    late MockQiitaApiClient mockApiClient;
    late QiitaItemRepositoryImpl repository;

    setUp(() {
      mockApiClient = MockQiitaApiClient();
      repository = QiitaItemRepositoryImpl(mockApiClient);
    });

    test('fetchItems converts models to entities', () async {
      const mockModels = [
        QiitaItemModel(
          title: 'Test Article 1',
          likesCount: 42,
          user: UserModel(id: 'user1'),
        ),
        QiitaItemModel(
          title: 'Test Article 2',
          likesCount: 100,
          user: UserModel(id: 'user2'),
        ),
      ];

      when(mockApiClient.fetchItems(page: 1, perPage: 20))
          .thenAnswer((_) async => mockModels);

      final result = await repository.fetchItems();

      expect(result, hasLength(2));
      expect(result[0], isA<QiitaItem>());
      expect(result[0].title, equals('Test Article 1'));
      expect(result[0].likesCount, equals(42));
      expect(result[0].userId, equals('user1'));
      expect(result[1].title, equals('Test Article 2'));
      expect(result[1].likesCount, equals(100));
      expect(result[1].userId, equals('user2'));
    });
  });
}