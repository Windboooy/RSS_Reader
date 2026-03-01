import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rss_dart/dart_rss.dart';
import '../models/feed_source.dart';
import '../services/rss_service.dart';

// RSS 解析服务
final rssServiceProvider = Provider((ref) => RssService());

// 订阅列表存储 Key
const _storageKey = 'rss_subscriptions';

// 订阅列表管理 (AsyncNotifier)
// 使用 AsyncNotifier 自动处理初始化加载状态，替代 StateNotifier
class FeedListNotifier extends AsyncNotifier<List<FeedSource>> {
  @override
  Future<List<FeedSource>> build() async {
    return _loadFromStorage();
  }

  Future<List<FeedSource>> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList(_storageKey);
    if (storedList != null) {
      return storedList.map((e) => FeedSource.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> addFeed(String url, String title) async {
    // 自动补全 URL 协议头 (如果在 Android 9+ 上使用 http，需要在 AndroidManifest 配置 cleartextTraffic)
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    // 获取当前状态列表（如果还未加载完成，给个空列表避免空指针）
    final currentList = state.value ?? [];

    final newFeed = FeedSource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      title: title.isEmpty ? url : title,
      addedAt: DateTime.now(),
    );

    final newList = [...currentList, newFeed];

    // 更新内存状态
    state = AsyncValue.data(newList);

    // 持久化存储
    await _saveToStorage(newList);
  }

  Future<void> removeFeed(String id) async {
    final currentList = state.value ?? [];
    final newList = currentList.where((feed) => feed.id != id).toList();

    state = AsyncValue.data(newList);
    await _saveToStorage(newList);
  }

  Future<void> updateFeed(String id, String newUrl, String newTitle) async {
    // 自动补全 URL 协议头
    if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
      newUrl = 'https://$newUrl';
    }

    final currentList = state.value ?? [];
    final newList = currentList.map((feed) {
      if (feed.id == id) {
        return FeedSource(
          id: feed.id,
          url: newUrl,
          title: newTitle.isEmpty ? newUrl : newTitle,
          addedAt: feed.addedAt,
        );
      }
      return feed;
    }).toList();

    state = AsyncValue.data(newList);
    await _saveToStorage(newList);
  }

  Future<void> _saveToStorage(List<FeedSource> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList = list.map((feed) => feed.toJson()).toList();
    await prefs.setStringList(_storageKey, stringList);
  }
}

// 供 UI 调用的 Provider - 订阅源列表
// 使用 AsyncNotifierProvider 替代 StateNotifierProvider
final feedListProvider =
    AsyncNotifierProvider<FeedListNotifier, List<FeedSource>>(() {
      return FeedListNotifier();
    });

// 获取特定 Feed 内容的 FutureProvider (用于详情页)
final feedContentProvider = FutureProvider.family<RssFeed, String>((
  ref,
  url,
) async {
  final service = ref.read(rssServiceProvider);
  return service.fetchFeed(url);
});
