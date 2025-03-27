import 'package:flutter/material.dart';
import 'comic_detail_page.dart'; // Import trang chi tiết truyện

class AllComicsListPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> comics;

  const AllComicsListPage({
    super.key,
    required this.title,
    required this.comics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: comics.length,
        itemExtent: 180, // Giữ cố định chiều cao để tăng hiệu suất
        itemBuilder: (context, index) {
          return ComicItem(comic: comics[index]);
        },
      ),
    );
  }
}

class ComicItem extends StatelessWidget {
  final Map<String, String> comic;

  const ComicItem({super.key, required this.comic});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = comic["cover_url"] ?? "";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComicDetailPage(comic: comic),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(51),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 80),
              ),
            ),
            const SizedBox(width: 10),

            // Thông tin truyện
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comic["comic_name"] ?? "Không có tên",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    comic["description"] ?? "Hiện không có mô tả",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
