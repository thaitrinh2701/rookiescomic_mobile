import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:rookiescomic_mobile/models/comics.dart'; // This import should include formatDate
import 'package:rookiescomic_mobile/models/chapter.dart';
import 'package:rookiescomic_mobile/screens/reading_comic_screen.dart';
import 'package:rookiescomic_mobile/screens/cart_screen.dart'; // Add this import

class ComicDetailPage extends StatefulWidget {
  final Comic comic; // Change to Comic type

  const ComicDetailPage({super.key, required this.comic});

  @override
  _ComicDetailPageState createState() => _ComicDetailPageState();
}

class _ComicDetailPageState extends State<ComicDetailPage> {
  bool isSaved = false;
  bool showFullDescription = false;
  int currentPage = 1;
  final int chaptersPerPage = 10;
  int totalPages = 1;
  final TextEditingController pageController = TextEditingController();
  bool isAscendingOrder = true; // New state variable for sorting order

  @override
  void initState() {
    super.initState();
    final int quantityChap =
        int.tryParse(widget.comic.quantityChap.toString() ?? '0') ?? 0;
    totalPages = (quantityChap / chaptersPerPage).ceil();
    pageController.text = currentPage.toString();
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    setState(() {
      currentPage = page;
      pageController.text = currentPage.toString();
    });
  }

  // New method to toggle sorting order
  void toggleSortOrder() {
    setState(() {
      isAscendingOrder = !isAscendingOrder;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int quantityChap =
        int.tryParse(widget.comic.quantityChap.toString() ?? '0') ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 250.0,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: widget.comic.coverUrl ?? '',
                      fit: BoxFit.cover,
                      errorWidget:
                          (context, url, error) =>
                              const Icon(Icons.broken_image, size: 80),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: widget.comic.coverUrl ?? '',
                                  width: 100,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.comic.comicName ?? 'Không có tên',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Người đăng: ${widget.comic['poster_name'] ?? 'Không rõ'}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Lượt xem: ${widget.comic.view ?? 0}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Ngày đăng: ${formatDate(widget.comic.createdDate)}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Start reading from the first chapter
                            if (quantityChap > 0) {
                              _navigateToReadingScreen(0);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: const Icon(Icons.menu_book),
                          label: const Text("Đọc truyện"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          Icons.bookmark,
                          size: 28,
                          color:
                              isSaved ? const Color(0xFF4D4FC1) : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isSaved = !isSaved;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Giới thiệu",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedCrossFade(
                        firstChild: Text(
                          widget.comic.description ?? 'Không có mô tả',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          widget.comic.description ?? 'Không có mô tả',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                        crossFadeState:
                            showFullDescription
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),

                      if ((widget.comic.description ?? '').length > 100)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showFullDescription = !showFullDescription;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                showFullDescription ? 'Thu gọn' : 'Xem thêm',
                                style: TextStyle(
                                  color: const Color(0xFF4D4FC1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                showFullDescription
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: const Color(0xFF4D4FC1),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  // Add chapter header with sort button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Danh sách chương",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: toggleSortOrder,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Text(
                                  isAscendingOrder ? "Tăng dần" : "Giảm dần",
                                  style: TextStyle(
                                    color: const Color(0xFF4D4FC1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isAscendingOrder
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: const Color(0xFF4D4FC1),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Modified SliverList for better lock visualization
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              // Determine chapter number based on sorting order
              int chapNumber;
              if (isAscendingOrder) {
                // Ascending: Start from the beginning of the current page
                chapNumber = (currentPage - 1) * chaptersPerPage + index + 1;
              } else {
                // Descending: Start from the end and go backwards
                chapNumber =
                    quantityChap -
                    ((currentPage - 1) * chaptersPerPage + index);
              }

              // Check if chapNumber is valid
              if (chapNumber <= 0 || chapNumber > quantityChap) return null;

              // Get chapter data if available
              Chapter? chapter;
              bool isLocked = false;
              bool isPaid = false;
              double price = 0.0;

              if (widget.comic.chapters != null &&
                  chapNumber <= widget.comic.chapters!.length) {
                chapter = widget.comic.chapters![chapNumber - 1];
                isLocked = chapter.isLocked;
                isPaid = chapter.chapterType == 'pay';
                price = chapter.price;
              }

              return Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border:
                      isPaid && isLocked
                          ? Border.all(
                            color: Colors.orange,
                            width: 2.0,
                          ) // Make border more visible
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        isPaid && isLocked
                            ? Colors.orange
                            : const Color(0xFF4D4FC1),
                    child:
                        isPaid && isLocked
                            ? const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 20,
                            )
                            : Text(
                              "$chapNumber",
                              style: const TextStyle(color: Colors.white),
                            ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        "Chương $chapNumber",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              isPaid && isLocked
                                  ? Colors.orange.shade800
                                  : Colors.black,
                        ),
                      ),
                      if (isPaid && isLocked)
                        Container(
                          margin: const EdgeInsets.only(left: 8.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                "KHÓA",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cập nhật ${DateTime.now().subtract(Duration(days: chapNumber)).day}/${DateTime.now().subtract(Duration(days: chapNumber)).month}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (isPaid && isLocked)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${price.toInt()} xu",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing:
                      isPaid && isLocked
                          ? ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_cart, size: 16),
                            label: const Text("Mua"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CartScreen(
                                        args: {
                                          'comic': widget.comic,
                                          'chapter': chapter,
                                        },
                                      ),
                                ),
                              );
                            },
                          )
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Convert to zero-based index for the chapter array
                    int chapterIndex = chapNumber - 1;
                    _navigateToReadingScreen(chapterIndex);
                  },
                ),
              );
            }, childCount: chaptersPerPage),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        currentPage > 1
                            ? () => goToPage(currentPage - 1)
                            : null,
                    icon: const Icon(Icons.chevron_left, size: 32),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 35,
                          child: TextField(
                            controller: pageController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            onSubmitted: (value) {
                              int? page = int.tryParse(value);
                              if (page != null) {
                                goToPage(page);
                              }
                            },
                          ),
                        ),
                        const Text(" / ", style: TextStyle(fontSize: 16)),
                        Text(
                          "$totalPages",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        currentPage < totalPages
                            ? () => goToPage(currentPage + 1)
                            : null,
                    icon: const Icon(Icons.chevron_right, size: 32),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update _navigateToReadingScreen to use Comic model
  void _navigateToReadingScreen(int chapterIndex) {
    try {
      // Validate chapter index
      if (widget.comic.chapters == null ||
          chapterIndex >= widget.comic.chapters!.length) {
        throw Exception("Invalid chapter index or no chapters available");
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ReadingComicScreen(
                comic: widget.comic,
                initialChapterIndex: chapterIndex,
                initialPageIndex: 0,
              ),
        ),
      );
    } catch (e) {
      print("Error navigating to reading screen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở truyện. Vui lòng thử lại sau.')),
      );
    }
  }
}
