import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';
import 'package:intl/intl.dart';

class RssService {
  // 获取并解析 RSS/Atom
  Future<RssFeed> fetchFeed(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 10)); // 设置 10 秒超时

      if (response.statusCode == 200) {
        // 尝试自动识别编码并解码 (http 包通常已经处理，但有时候会有乱码)
        // rss_dart 会自动检测是 RSS 还是 Atom
        // 注意：某些 feed 内容可能编码问题，dart_rss 处理较好
        // 使用 utf8.decode 确保中文正常显示 (如果是别的编码需要 charset_converter)
        String body = response.body;

        // 简单的编码修复尝试: 如果 response.body 是乱码，尝试手动解码 bytes
        // 这里默认相信 http 包的 Content-Type 判断，如果需要更强鲁棒性可以引入 charset_converter
        try {
          // 再次确保它是 UTF-8 (因为有些服务器即使声明了 GBK, body 也是 UTF-8，反之亦然)
          // 但 http.get 的 response.body 已经做过解码。
          // 如果这里报错，说明 body 格式有问题
          return RssFeed.parse(body);
        } catch (e) {
          // 如果解析失败，可能是因为有些字符不规范，尝试清理
          // 或者直接抛出
          print('RSS Parse Error for $url: $e');
          print(
            'Response body preview: ${body.substring(0, body.length > 500 ? 500 : body.length)}',
          );
          rethrow;
        }
      } else {
        throw Exception('Failed to load feed: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('请求超时，请检查网络或该源无法访问');
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
