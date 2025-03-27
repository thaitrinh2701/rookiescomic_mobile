import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rookiescomic_mobile/pages/comic_detail_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:rookiescomic_mobile/models/comics.dart'; // Add this import
import 'dart:ui';

class TopComicImageSlider extends StatefulWidget {
  final List<Map<String, dynamic>> comics;

  const TopComicImageSlider({super.key, required this.comics});

  @override
  State<TopComicImageSlider> createState() => _TopComicImageSliderState();
}

class _TopComicImageSliderState extends State<TopComicImageSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Hiệu ứng làm mờ nền với ảnh bìa của truyện hiện tại
        Positioned.fill(
          child:
              widget.comics.isNotEmpty
                  ? ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Image.network(
                      widget.comics[_currentIndex]["cover_url"] ?? "",
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 80),
                    ),
                  )
                  : Container(),
        ),
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.3))),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: 300,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.7,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                itemCount: widget.comics.length,
                itemBuilder: (context, index, realIndex) {
                  final comic = widget.comics[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ComicDetailPage(
                                comic: Comic.fromJson(
                                  comic,
                                ), // Convert Map to Comic
                              ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        comic["cover_url"] ?? "",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: widget.comics.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: Color(0xFF4D4FC1),
                dotHeight: 8.0,
                dotWidth: 8.0,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }
}
