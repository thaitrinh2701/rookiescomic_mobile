import 'package:rookiescomic_mobile/models/chapter.dart';

List<ChapterContent> sortChapterImages(List<ChapterContent> images) {
  final sorted = List<ChapterContent>.from(
    images,
  ); // Tạo bản copy rõ ràng với kiểu cụ thể

  sorted.sort((a, b) {
    final fileNameA = a.contentUrl.split('/').last.split('?').first;
    final fileNameB = b.contentUrl.split('/').last.split('?').first;

    final orderA = int.tryParse(fileNameA.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final orderB = int.tryParse(fileNameB.replaceAll(RegExp(r'\D'), '')) ?? 0;

    return orderA.compareTo(orderB);
  });

  return sorted;
}
