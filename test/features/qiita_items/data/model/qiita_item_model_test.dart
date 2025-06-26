import 'package:flutter_test/flutter_test.dart';
import 'package:qiita_client_app/features/qiita_items/data/model/qiita_item_model.dart';
import 'package:qiita_client_app/features/qiita_items/domain/entity/qiita_item.dart';

void main() {
  group('QiitaItemModel', () {
    test('fromJson creates model from valid JSON', () {
      final json = {
        'title': 'Test Article',
        'likes_count': 42,
        'user': {
          'id': 'test_user',
        },
      };

      final model = QiitaItemModel.fromJson(json);

      expect(model.title, equals('Test Article'));
      expect(model.likesCount, equals(42));
      expect(model.user.id, equals('test_user'));
    });
  });

  group('UserModel', () {
    test('fromJson creates model from valid JSON', () {
      final json = {
        'id': 'test_user',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, equals('test_user'));
    });
  });

  group('QiitaItemModelX extension', () {
    test('toEntity converts model to entity correctly', () {
      const user = UserModel(id: 'test_user');
      const model = QiitaItemModel(
        title: 'Test Article',
        likesCount: 42,
        user: user,
      );

      final entity = model.toEntity();

      expect(entity, isA<QiitaItem>());
      expect(entity.title, equals('Test Article'));
      expect(entity.likesCount, equals(42));
      expect(entity.userId, equals('test_user'));
    });

    test('toEntity preserves all data', () {
      const user = UserModel(id: 'another_user');
      const model = QiitaItemModel(
        title: 'Another Article',
        likesCount: 100,
        user: user,
      );

      final entity = model.toEntity();

      expect(entity.title, equals(model.title));
      expect(entity.likesCount, equals(model.likesCount));
      expect(entity.userId, equals(model.user.id));
    });
  });
}