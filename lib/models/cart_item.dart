class CartItem {
  final String comicId;
  final String comicName;
  final String coverUrl;
  final String chapterId;
  final String chapterName;
  final double price;

  CartItem({
    required this.comicId,
    required this.comicName,
    required this.coverUrl,
    required this.chapterId,
    required this.chapterName,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'comicId': comicId,
      'comicName': comicName,
      'coverUrl': coverUrl,
      'chapterId': chapterId,
      'chapterName': chapterName,
      'price': price,
    };
  }

  static CartItem fromMap(Map<String, dynamic> map) {
    return CartItem(
      comicId: map['comicId'] ?? '',
      comicName: map['comicName'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      chapterId: map['chapterId'] ?? '',
      chapterName: map['chapterName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }
}
