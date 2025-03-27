class Chapter {
  final String chapterId;
  final String chapterName;
  final DateTime createdDate;
  final int view;
  final List<ChapterContent> chapterContent;
  final String chapterType; // 'free' or 'pay'
  final double price; // Price for paid chapters
  final bool isLocked; // Locked status

  Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.createdDate,
    required this.view,
    required this.chapterContent,
    this.chapterType = 'free',
    this.price = 0.0,
    this.isLocked = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapter_id']?.toString() ?? '',
      chapterName: json['chapter_name']?.toString() ?? '',
      createdDate:
          json['created_date'] != null
              ? (json['created_date'] is DateTime
                  ? json['created_date']
                  : DateTime.parse(json['created_date'].toString()))
              : DateTime.now(),
      view: int.tryParse(json['view']?.toString() ?? '0') ?? 0,
      chapterContent:
          json['chapter_content'] is List
              ? (json['chapter_content'] as List)
                  .map((content) => ChapterContent.fromJson(content))
                  .toList()
              : [],
      chapterType: json['chapter_type']?.toString() ?? 'free',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      isLocked: json['is_locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'created_date': createdDate.toIso8601String(),
      'view': view,
      'chapter_content':
          chapterContent.map((content) => content.toJson()).toList(),
      'chapter_type': chapterType,
      'price': price,
      'is_locked': isLocked,
    };
  }
}

class ChapterContent {
  final String contentId;
  final String contentUrl;

  ChapterContent({required this.contentId, required this.contentUrl});

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    return ChapterContent(
      contentId: json['content_id']?.toString() ?? '',
      contentUrl: json['content_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'content_id': contentId, 'content_url': contentUrl};
  }
}
