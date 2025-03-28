import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:rookiescomic_mobile/models/comics.dart'; // This import should include formatDate
import 'package:rookiescomic_mobile/models/chapter.dart';
import 'package:rookiescomic_mobile/screens/reading_comic_screen.dart';
import 'package:rookiescomic_mobile/screens/cart_screen.dart'; // Add this import
import 'package:rookiescomic_mobile/apis/comics_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int quantityChap = 0;
  int? userRole;

  Future<int?> getRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? roleString = prefs.getString("role");
      print("Retrieved roleString: $roleString");
      return roleString != null ? int.tryParse(roleString) : null;
    } catch (e) {
      print("Error getting role: $e");
      return null;
    }
  }

  Future<void> _loadUserRole() async {
    userRole = await getRole() ?? 0; // Giá trị mặc định là 0 nếu null
    print("🔑 Loaded user role: $userRole"); // Debug user role
    setState(() {}); // Cập nhật lại UI
  }

  // Method to check if a chapter has been purchased
  bool _isChapterPurchased(String chapterId) {
    // Access the static set of purchased chapter IDs from CartScreen
    return CartScreen.purchasedChapterIds.contains(chapterId);
  }

  @override
  void initState() {
    super.initState();
    quantityChap = int.tryParse(widget.comic.quantityChap.toString()) ?? 0;
    pageController.text = currentPage.toString();
    _loadUserRole();

    if (widget.comic.comicId.isEmpty) {
      print("❌ comicId is empty, skipping fetchChapters");
      return;
    }

    print('📌 Comic ID before fetching chapters: ${widget.comic.comicId}');

    // Fetch chapters from API
    fetchChapters(widget.comic.comicId)
        .then((fetchedChapters) {
          setState(() {
            // Sort chapters based on their chapter number in the name
            fetchedChapters.sort((a, b) {
              // Extract chapter numbers from the chapter names
              RegExp regExp = RegExp(r'Chapter (\d+)');
              var matchA = regExp.firstMatch(a.chapterName);
              var matchB = regExp.firstMatch(b.chapterName);

              int numA =
                  matchA != null
                      ? int.tryParse(matchA.group(1) ?? '0') ?? 0
                      : 0;
              int numB =
                  matchB != null
                      ? int.tryParse(matchB.group(1) ?? '0') ?? 0
                      : 0;

              return numA.compareTo(numB); // Sort in ascending order
            });

            widget.comic.chapters = fetchedChapters;
            totalPages = (fetchedChapters.length / chaptersPerPage).ceil();
            quantityChap = fetchedChapters.length;
          });
        })
        .catchError((error) {
          print('❌ Error fetching chapters: $error');
        });
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
                                      "Người đăng: ${widget.comic.posterName}",
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
          if (widget.comic.chapters != null &&
              widget.comic.chapters!.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                // Get the correct chapter index based on current page and sorting
                int listIndex;
                if (isAscendingOrder) {
                  // Ascending order (1, 2, 3...)
                  listIndex = (currentPage - 1) * chaptersPerPage + index;
                } else {
                  // Descending order (10, 9, 8...)
                  listIndex =
                      widget.comic.chapters!.length -
                      1 -
                      ((currentPage - 1) * chaptersPerPage + index);
                }

                // Check if the index is valid
                if (listIndex < 0 || listIndex >= widget.comic.chapters!.length)
                  return null;

                // Get the chapter and extract the chapter number from name
                Chapter chapter = widget.comic.chapters![listIndex];

                // Check if this chapter has been purchased
                bool isPurchased = false;
                if (chapter.chapterId.isNotEmpty) {
                  // Try to access the cart screen's purchased chapters
                  isPurchased = CartScreen.purchasedChapterIds.contains(
                    chapter.chapterId,
                  );
                }

                // Extract chapter number from name (e.g., "Chapter 5: Title" -> 5)
                RegExp regExp = RegExp(r'Chapter (\d+)');
                var match = regExp.firstMatch(chapter.chapterName);
                String displayNumber =
                    match != null
                        ? match.group(1) ?? "${index + 1}"
                        : "${index + 1}";

                // Debug chapter details
                print(
                  "📑 Processing Chapter $displayNumber (index $listIndex):",
                );

                bool isPaid = chapter.chapterType == 'pay';
                bool isLocked = false;

                double price = chapter.price;
                if (isPaid && (price <= 0)) {
                  price = 999; // Default price for paid chapters
                }

                // Apply role-based locking rules
                if (isPurchased) {
                  // If chapter was purchased, it's unlocked regardless of role
                  isLocked = false;
                  print("   Chapter was purchased, unlocking it");
                } else if (userRole == 5) {
                  // For role 5, lock paid chapters
                  isLocked = isPaid;
                  print(
                    "   Role 5 logic: isLocked = $isLocked (based on isPaid)",
                  );
                } else if (userRole == 7) {
                  // For role 7, all chapters are unlocked
                  isLocked = false;
                  print(
                    "   Role 7 logic: isLocked = false (all chapters unlocked)",
                  );
                } else if (userRole == 6 || userRole == 8) {
                  // For roles 6 and 8, all chapters are free
                  isLocked = false;
                  print("   Role 6/8 logic: isLocked = false (all free)");
                } else {
                  // For other roles, use default locking behavior
                  isLocked = chapter.isLocked;
                  print(
                    "   Default role logic: isLocked = ${chapter.isLocked}",
                  );
                }

                print("   Final lock status: $isLocked");
                print("   Final price: $price");

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
                            ? Border.all(color: Colors.orange, width: 2.0)
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
                                displayNumber,
                                style: const TextStyle(color: Colors.white),
                              ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          "Chương $displayNumber",
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
                          "Cập nhật ${DateTime.now().subtract(Duration(days: listIndex)).day}/${DateTime.now().subtract(Duration(days: listIndex)).month}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
                                  "$price xu",
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
                                // Create modified chapter with correct price
                                final chapterForCart = Chapter(
                                  chapterId: chapter.chapterId,
                                  chapterName: chapter.chapterName,
                                  createdDate: chapter.createdDate,
                                  view: chapter.view,
                                  chapterContent: chapter.chapterContent,
                                  chapterType: chapter.chapterType,
                                  price: price, // Use the corrected price
                                  isLocked: chapter.isLocked,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CartScreen(
                                          args: {
                                            'comic': widget.comic,
                                            'chapter':
                                                chapterForCart, // Use the fixed chapter
                                          },
                                        ),
                                  ),
                                );
                              },
                            )
                            : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (!isPaid || !isLocked) {
                        _navigateToReadingScreen(
                          listIndex,
                        ); // Use the correct index in the sorted list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Bạn cần mua chương này để đọc!"),
                          ),
                        );
                      }
                    },
                  ),
                );
              }, childCount: chaptersPerPage),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Không có chương nào để hiển thị.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
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
