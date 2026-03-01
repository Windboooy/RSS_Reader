import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';
import 'package:intl/intl.dart';

class RssService {
  // 获取并解析 RSS/Atom
  Future<RssFeed> fetchFeed(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // rss_dart 会自动检测是 RSS 还是 Atom
        // 注意：某些 feed 内容可能编码问题，dart_rss 处理较好
        return RssFeed.parse(response.body);
      } else {
        throw Exception('Failed to load feed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching feed: $e');
    }
  }

  // 辅助方法：把不同格式的 item 统一转换为简单对象（可选，但在 UI 层直接处理 RssItem 也可以）
  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      // 尝试解析常见的 RSS 时间格式
      final date = HttpDate.parse(dateStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
