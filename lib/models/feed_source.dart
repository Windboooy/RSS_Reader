import 'dart:convert';

class FeedSource {
  final String id;
  final String url;
  final String title;
  final DateTime addedAt;

  FeedSource({
    required this.id,
    required this.url,
    required this.title,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FeedSource.fromMap(Map<String, dynamic> map) {
    return FeedSource(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      title: map['title'] ?? '未知订阅',
      addedAt: DateTime.parse(map['addedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedSource.fromJson(String source) =>
      FeedSource.fromMap(json.decode(source));
}
