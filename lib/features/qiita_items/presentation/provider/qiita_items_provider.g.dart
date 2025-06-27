// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qiita_items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'209142896051c16d5fa3f133e8bc388967c13f9e';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$qiitaApiClientHash() => r'94cb3d3edd1ee00a50ec9e05154ebc04fa85257c';

/// See also [qiitaApiClient].
@ProviderFor(qiitaApiClient)
final qiitaApiClientProvider = AutoDisposeProvider<QiitaApiClient>.internal(
  qiitaApiClient,
  name: r'qiitaApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$qiitaApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QiitaApiClientRef = AutoDisposeProviderRef<QiitaApiClient>;
String _$qiitaItemRepositoryHash() =>
    r'5244b0a3259f9038b8c64960c478e0366b7334a8';

/// See also [qiitaItemRepository].
@ProviderFor(qiitaItemRepository)
final qiitaItemRepositoryProvider =
    AutoDisposeProvider<QiitaItemRepository>.internal(
      qiitaItemRepository,
      name: r'qiitaItemRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$qiitaItemRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QiitaItemRepositoryRef = AutoDisposeProviderRef<QiitaItemRepository>;
String _$qiitaItemsPaginationUseCaseHash() =>
    r'6016530003c65a3d040c3496fdffed323722a533';

/// See also [qiitaItemsPaginationUseCase].
@ProviderFor(qiitaItemsPaginationUseCase)
final qiitaItemsPaginationUseCaseProvider =
    AutoDisposeProvider<QiitaItemsPaginationUseCase>.internal(
      qiitaItemsPaginationUseCase,
      name: r'qiitaItemsPaginationUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$qiitaItemsPaginationUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QiitaItemsPaginationUseCaseRef =
    AutoDisposeProviderRef<QiitaItemsPaginationUseCase>;
String _$qiitaItemsPaginationNotifierHash() =>
    r'f72940291dec283e181133a393e0ec21f77d90f4';

/// See also [QiitaItemsPaginationNotifier].
@ProviderFor(QiitaItemsPaginationNotifier)
final qiitaItemsPaginationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      QiitaItemsPaginationNotifier,
      QiitaItemsPage
    >.internal(
      QiitaItemsPaginationNotifier.new,
      name: r'qiitaItemsPaginationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$qiitaItemsPaginationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$QiitaItemsPaginationNotifier =
    AutoDisposeAsyncNotifier<QiitaItemsPage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
