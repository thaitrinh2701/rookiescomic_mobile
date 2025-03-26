import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rookiescomic_mobile/models/comics.dart';

class ComicDetailPage extends StatefulWidget {
  final Map<String, dynamic> comic;

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

  @override
  void initState() {
    super.initState();
    final int quantityChap =
        int.tryParse(widget.comic['quantity_chap']?.toString() ?? '0') ?? 0;
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

  @override
  Widget build(BuildContext context) {
    final int quantityChap =
        int.tryParse(widget.comic['quantity_chap']?.toString() ?? '0') ?? 0;

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
                      imageUrl: widget.comic['cover_url'] ?? '',
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
                                  imageUrl: widget.comic['cover_url'] ?? '',
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
                                      widget.comic['comic_name'] ??
                                          'Không có tên',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Người đăng: ${widget.comic['user_id'] ?? 'Không rõ'}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Lượt xem: ${widget.comic['view'] ?? 0}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Ngày đăng: ${formatDate(widget.comic['created_date'])}",
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
                          onPressed: () {},
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
                          widget.comic['description'] ?? 'Không có mô tả',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          widget.comic['description'] ?? 'Không có mô tả',
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

                      if ((widget.comic['description'] ?? '').length > 100)
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              int chapNumber = (currentPage - 1) * chaptersPerPage + index + 1;
              if (chapNumber > quantityChap) return null;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF4D4FC1),
                  child: Text(
                    "$chapNumber",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text("Chương $chapNumber"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
}
