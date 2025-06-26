import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qiita_client_app/features/qiita_items/presentation/provider/qiita_items_provider.dart';

class QiitaItemListPage extends ConsumerWidget {
  const QiitaItemListPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncQiitaItems = ref.watch(qiitaItemsNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qiita 記事一覧'),
      ),
      body: asyncQiitaItems.when(
          data: (items) => RefreshIndicator(
              child: ListView.separated(
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        '♥ ${item.likesCount} by ${item.userId}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const Divider(height: 1, thickness: .5),
                  itemCount: items.length,
              ),
              onRefresh: () => ref.read(qiitaItemsNotifierProvider.notifier).refresh()),
          error: (error, stackTrace) => Center(
            child: Text('エラーが発生しました：$error'),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          )
      ),
    );
  }
}