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
String _$qiitaItemsUseCaseHash() => r'44c124da0b0dbf94dc108cf167e2a1d44e1b647e';

/// See also [qiitaItemsUseCase].
@ProviderFor(qiitaItemsUseCase)
final qiitaItemsUseCaseProvider =
    AutoDisposeProvider<QiitaItemsUseCase>.internal(
      qiitaItemsUseCase,
      name: r'qiitaItemsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$qiitaItemsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QiitaItemsUseCaseRef = AutoDisposeProviderRef<QiitaItemsUseCase>;
String _$qiitaItemsNotifierHash() =>
    r'9c32483c4d78d1644008c17b8902d1227bf78cec';

/// See also [QiitaItemsNotifier].
@ProviderFor(QiitaItemsNotifier)
final qiitaItemsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      QiitaItemsNotifier,
      List<QiitaItem>
    >.internal(
      QiitaItemsNotifier.new,
      name: r'qiitaItemsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$qiitaItemsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$QiitaItemsNotifier = AutoDisposeAsyncNotifier<List<QiitaItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
