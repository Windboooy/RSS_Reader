import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rss_dart/dart_rss.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import 'article_webview.dart';

class FeedDetailScreen extends ConsumerWidget {
  final String url;
  final String title;

  const FeedDetailScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听特定 URL 的 RSS 数据
    final asyncFeed = ref.watch(feedContentProvider(url));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // 强制刷新：invalidate 会触发重新 fetch
            onPressed: () => ref.invalidate(feedContentProvider(url)),
          ),
        ],
      ),
      body: asyncFeed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('加载失败:\n$err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(feedContentProvider(url)),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
        data: (feed) {
          final items = feed.items;
          if (items.isEmpty) {
            return const Center(child: Text('没有找到文章'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(feedContentProvider(url)),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(
                    item.title ?? '无标题',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _formatDate(item.pubDate),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleScreen(item: item),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      // 简单处理：通常 RSS 日期很长，截取前部分显示即可
      // 如果想要精确格式化，可以使用 intl 包的 DateFormat 解析 RFC822 等格式
      if (dateStr.length > 25) return dateStr.substring(0, 25);
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }
}

// ------ 文章阅读页 ------

class ArticleScreen extends StatelessWidget {
  final RssItem item;

  const ArticleScreen({super.key, required this.item});

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null) return;
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 优先使用 content:encoded (全文), 其次 description (摘要)
    final content = item.content?.value ?? item.description ?? '无内容';

    return Scaffold(
      appBar: AppBar(
        // title: Text(item.title ?? '文章详情'), // 标题太长可能显示不全，这里省略
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _launchUrl(item.link),
            tooltip: '在浏览器打开',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? '',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (item.pubDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  item.pubDate!,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            // 添加阅读原文按钮
            if (item.link != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleWebView(
                          url: item.link!,
                          title: item.title ?? '文章详情',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.web),
                  label: const Text('阅读原文 (完整内容)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            const Divider(),
            const SizedBox(height: 8),
            // 使用 flutter_widget_from_html 原生渲染 HTML
            HtmlWidget(
              content,
              textStyle: const TextStyle(fontSize: 16, height: 1.5),
              onTapUrl: (url) async {
                await _launchUrl(url);
                return true;
              },
            ),
            const SizedBox(height: 40), // 底部留白
          ],
        ),
      ),
    );
  }
}
