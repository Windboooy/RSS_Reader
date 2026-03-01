import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/feed_source.dart';
import 'feed_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听订阅列表变化 (AsyncValue<List<FeedSource>>)
    final asyncFeedList = ref.watch(feedListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的订阅')),
      body: asyncFeedList.when(
        data: (feedList) {
          if (feedList.isEmpty) {
            return const Center(
              child: Text(
                '还没有订阅源\n点击右下角添加',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: feedList.length,
            itemBuilder: (context, index) {
              final feed = feedList[index];
              return ListTile(
                leading: const Icon(Icons.rss_feed),
                title: Text(
                  feed.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  feed.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                // 点击进入详情
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FeedDetailScreen(url: feed.url, title: feed.title),
                    ),
                  );
                },
                // 长按弹出菜单
                onLongPress: () => _showFeedOptions(context, ref, feed),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('加载失败: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFeedDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 底部弹出选项卡
  void _showFeedOptions(BuildContext context, WidgetRef ref, FeedSource feed) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('更改链接/标题'),
              onTap: () {
                Navigator.pop(context); // 关闭底部菜单
                _showEditFeedDialog(context, ref, feed);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除订阅', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // 关闭底部菜单
                _confirmDelete(context, ref, feed);
              },
            ),
          ],
        );
      },
    );
  }

  // 添加订阅弹窗
  void _showAddFeedDialog(BuildContext context, WidgetRef ref) {
    final urlController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加 RSS 订阅'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'RSS 链接 (必填)',
                hintText: 'https://...',
                helperText: '例如: https://sspai.com/feed',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '标题 (可选)',
                hintText: '自定义名称',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                // 调用 provider 添加
                ref
                    .read(feedListProvider.notifier)
                    .addFeed(
                      urlController.text.trim(),
                      titleController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 编辑订阅弹窗
  void _showEditFeedDialog(
    BuildContext context,
    WidgetRef ref,
    FeedSource feed,
  ) {
    final urlController = TextEditingController(text: feed.url);
    final titleController = TextEditingController(text: feed.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更改订阅'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'RSS 链接',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '自定义名称',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                // 调用 provider 更新
                ref
                    .read(feedListProvider.notifier)
                    .updateFeed(
                      feed.id,
                      urlController.text.trim(),
                      titleController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 删除确认弹窗
  void _confirmDelete(BuildContext context, WidgetRef ref, FeedSource feed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${feed.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              ref.read(feedListProvider.notifier).removeFeed(feed.id);
              Navigator.pop(context); // 关闭对话框
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('已删除 ${feed.title}')));
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
