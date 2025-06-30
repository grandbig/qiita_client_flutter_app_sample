import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qiita_client_app/features/qiita_items/presentation/provider/qiita_items_provider.dart';

class QiitaItemListPage extends ConsumerWidget {
  const QiitaItemListPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncQiitaItemsPage = ref.watch(qiitaItemsPaginationNotifierProvider);
    
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: SafeArea(
        child: asyncQiitaItemsPage.when(
          data: (itemsPage) => _buildDataView(itemsPage, ref),
          error: (error, stackTrace) => _buildErrorView(error, ref),
          loading: () => _buildLoadingView(),
        ),
      ),
    );
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return const CupertinoNavigationBar(
      middle: Text(
        'Qiita 記事一覧',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      backgroundColor: CupertinoColors.systemBackground,
      border: Border(
        bottom: BorderSide(
          color: CupertinoColors.separator,
          width: 0.0,
        ),
      ),
    );
  }

  Widget _buildDataView(dynamic itemsPage, WidgetRef ref) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () => ref.read(qiitaItemsPaginationNotifierProvider.notifier).refresh(),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _buildListItem(context, i, itemsPage, ref),
            childCount: itemsPage.items.length + 
                       (itemsPage.isLoadingMore || !itemsPage.hasMore ? 1 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: CupertinoColors.destructiveRed,
            ),
            const SizedBox(height: 16),
            const Text(
              'エラーが発生しました',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: () => ref.read(qiitaItemsPaginationNotifierProvider.notifier).refresh(),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget _buildListItem(BuildContext context, int i, dynamic itemsPage, WidgetRef ref) {
    // 通常のアイテム表示
    if (i < itemsPage.items.length) {
      final item = itemsPage.items[i];
      final isLastItem = i == itemsPage.items.length - 1;
      
      // 最後から3番目のアイテムで次のページを読み込む（より滑らかな無限スクロール）
      if (i == itemsPage.items.length - 3 && 
          itemsPage.hasMore && 
          !itemsPage.isLoadingMore) {
        // 非同期で読み込み開始
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(qiitaItemsPaginationNotifierProvider.notifier).loadMore();
        });
      }
      
      return Column(
        children: [
          CupertinoListTile(
            title: Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: CupertinoColors.label,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '♥ ${item.likesCount} by ${item.userId}',
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: const CupertinoListTileChevron(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          // Cupertinoスタイルのセパレータ（最後のアイテム以外）
          if (!isLastItem)
            Container(
              height: 0.5,
              margin: const EdgeInsets.only(left: 16),
              color: CupertinoColors.separator,
            ),
        ],
      );
    }
    
    // 最後のアイテム + ローディングインジケーター
    if (i == itemsPage.items.length && itemsPage.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CupertinoActivityIndicator(),
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
              color: CupertinoColors.secondaryLabel,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}