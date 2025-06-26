import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';
import 'package:qiita_client_app/features/qiita_items/domain/repository/qiita_item_repository.dart';
import 'package:qiita_client_app/features/qiita_items/domain/usecase/qiita_items_usecase.dart';

import 'qiita_items_usecase_test.mocks.dart';

@GenerateMocks([QiitaItemRepository])
void main() {
  group('QiitaItemsUseCase', () {
    late MockQiitaItemRepository mockRepository;
    late QiitaItemsUseCase useCase;

    setUp(() {
      mockRepository = MockQiitaItemRepository();
      useCase = QiitaItemsUseCase(mockRepository);
    });

    test('call delegates to repository', () async {
      const mockItems = [
        QiitaItem(
          title: 'Test Article',
          likesCount: 42,
          userId: 'user1',
        ),
      ];

      when(mockRepository.fetchItems(page: 1, perPage: 20))
          .thenAnswer((_) async => mockItems);

      final result = await useCase.call();

      expect(result, equals(mockItems));
      verify(mockRepository.fetchItems(page: 1, perPage: 20)).called(1);
    });
  });
}