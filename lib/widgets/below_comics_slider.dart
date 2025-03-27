import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rookiescomic_mobile/pages/view_all_comics_page.dart';

class ComicSlider extends StatelessWidget {
  final List<Map<String, dynamic>> comics;
  final String title;
  final Function(Map<String, dynamic>) onTapComic;

  const ComicSlider({
    super.key,
    required this.comics,
    required this.title,
    required this.onTapComic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize:
          MainAxisSize.min, // Giới hạn chiều cao của Column tránh overflow
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the AllComicsListPage instead of creating a new scaffold
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              AllComicsListPage(title: title, comics: comics),
                    ),
                  );
                },
                child: const Text(
                  "Tất cả",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4D4FC1),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        /// FIX CHÍNH: Bọc Slider trong `SizedBox` với chiều cao lớn hơn
        SizedBox(
          height: 230, // Tăng chiều cao để tránh overflow
          child: CarouselSlider.builder(
            itemCount: comics.length,
            options: CarouselOptions(
              height: 210, // Đảm bảo đủ không gian cho ảnh và text
              autoPlay: true,
              enlargeCenterPage: false,
              viewportFraction: 0.45, // Tăng kích thước hình ảnh
              onPageChanged: (index, reason) {
                // setState(() {
                //   _currentIndex = index;
                // });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final comic = comics[index];
              return GestureDetector(
                onTap: () => onTapComic(comic),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ngăn Column mở rộng vô hạn
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        comic["cover_url"] ?? "",
                        fit: BoxFit.cover,
                        width: 130,
                        height: 180, // Tăng chiều cao ảnh để hiển thị đẹp hơn
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 130, // Đảm bảo text không bị cắt
                      child: Text(
                        (comic["comic_name"]?.length ?? 0) > 20
                            ? "${comic["comic_name"]!.substring(0, 20)}..."
                            : comic["comic_name"] ?? "Không có",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
