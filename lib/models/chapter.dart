class Chapter {
  final String chapterId;
  final String chapterName;
  final DateTime createdDate;
  final int view;
  final List<ChapterContent> chapterContent;
  final String chapterType;
  final double price;
  final bool isLocked;

  Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.createdDate,
    required this.view,
    required this.chapterContent,
    this.chapterType = 'free',
    this.price = 999.0,
    this.isLocked = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId']?.toString() ?? '',
      chapterName: json['chapterName']?.toString() ?? '',
      createdDate:
          DateTime.tryParse(json['publishedDate']?.toString() ?? '') ??
          DateTime.now(),
      view: int.tryParse(json['view']?.toString() ?? '0') ?? 0,
      chapterContent:
          (json['chapterImages'] as List<dynamic>? ?? [])
              .map((img) => ChapterContent.fromJson(img))
              .toList(),
      chapterType: json['type']?.toString() == '1' ? 'pay' : 'free',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      isLocked: json['type']?.toString() == '1', // Nếu type là 'pay', thì khóa
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'chapterName': chapterName,
      'createdDate': createdDate.toIso8601String(),
      'view': view,
      'chapterContent':
          chapterContent.map((content) => content.toJson()).toList(),
      'chapterType': chapterType,
      'price': price,
      'isLocked': isLocked,
    };
  }
}

class ChapterContent {
  final String contentId;
  final String contentUrl;

  ChapterContent({required this.contentId, required this.contentUrl});

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    return ChapterContent(
      contentId: json['imageId']?.toString() ?? '',
      contentUrl: json['imageURL'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {'contentId': contentId, 'contentUrl': contentUrl};
  }
}
