import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qiita_client_app/features/qiita_items/presentation/provider/qiita_items_provider.dart';

class QiitaItemListPage extends ConsumerWidget {
  const QiitaItemListPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncQiitaItemsPage = ref.watch(qiitaItemsPaginationNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qiita 記事一覧'),
      ),
      body: asyncQiitaItemsPage.when(
        data: (itemsPage) => RefreshIndicator(
          onRefresh: () => ref.read(qiitaItemsPaginationNotifierProvider.notifier).refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // 画面の90%以上スクロールしたら次のページを読み込む
              if (scrollInfo.metrics.pixels / scrollInfo.metrics.maxScrollExtent > 0.9) {
                ref.read(qiitaItemsPaginationNotifierProvider.notifier).loadMore();
              }
              return false;
            },
            child: ListView.separated(
              itemBuilder: (context, i) {
                // 通常のアイテム表示
                if (i < itemsPage.items.length) {
                  final item = itemsPage.items[i];
                  return ListTile(
                    title: Text(item.title),
                    subtitle: Text(
                      '♥ ${item.likesCount} by ${item.userId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                
                // 最後のアイテム + ローディングインジケーター
                if (i == itemsPage.items.length && itemsPage.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                // 最後のアイテム + 終了メッセージ
                if (i == itemsPage.items.length && !itemsPage.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '全ての記事を読み込みました',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
              separatorBuilder: (_, index) {
                // 最後のアイテムの場合はセパレータを表示しない
                if (index >= itemsPage.items.length - 1) {
                  return const SizedBox.shrink();
                }
                return const Divider(height: 1, thickness: .5);
              },
              itemCount: itemsPage.items.length + 
                         (itemsPage.isLoadingMore || !itemsPage.hasMore ? 1 : 0),
            ),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('エラーが発生しました：$error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(qiitaItemsPaginationNotifierProvider.notifier).refresh(),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}