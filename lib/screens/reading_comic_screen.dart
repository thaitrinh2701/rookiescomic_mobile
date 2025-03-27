import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:rookiescomic_mobile/models/comics.dart';
import 'package:rookiescomic_mobile/models/chapter.dart'; // Add this import
import 'package:rookiescomic_mobile/screens/cart_screen.dart'; // Add this import
import 'package:url_launcher/url_launcher.dart'; // Add this import

class ReadingComicScreen extends StatefulWidget {
  final Comic comic; // Change to Comic type
  final int initialChapterIndex;
  final int initialPageIndex;

  const ReadingComicScreen({
    Key? key,
    required this.comic,
    this.initialChapterIndex = 0,
    this.initialPageIndex = 0,
  }) : super(key: key);

  @override
  State<ReadingComicScreen> createState() => _ReadingComicScreenState();
}

class _ReadingComicScreenState extends State<ReadingComicScreen> {
  late PageController _pageController;
  late int _currentChapterIndex;
  late int _currentPageIndex;
  bool _isFullScreen = false;
  bool _showControls = true;
  bool _showSettings = false;
  double _brightness = 1.0;
  bool _invertColors = false;

  // Reading direction options
  final List<String> _readingDirections = [
    'Vertical',
    'Left to Right',
    'Right to Left',
  ];
  String _selectedReadingDirection = 'Vertical';

  // Currently supported page layouts
  final List<String> _layouts = ['Single Page', 'Double Page', 'Continuous'];
  String _selectedLayout = 'Continuous';

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _currentPageIndex = widget.initialPageIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _pageController = PageController(initialPage: _currentPageIndex);
      });
    });

    _setSystemUIOverlays();
    _debugComicStructure();
  }

  // Add a method to debug the comic structure
  void _debugComicStructure() {
    print("----------- COMIC DATA STRUCTURE DEBUG -----------");
    print("Comic name: ${widget.comic.comicName}");

    if (widget.comic.chapters != null && widget.comic.chapters!.isNotEmpty) {
      print("Number of chapters: ${widget.comic.chapters!.length}");

      for (int i = 0; i < widget.comic.chapters!.length; i++) {
        var chapter = widget.comic.chapters![i];
        print("Chapter $i: ${chapter.chapterName}");
        print("  Pages in chapter $i: ${chapter.chapterContent.length}");

        if (chapter.chapterContent.isNotEmpty) {
          print("  First page structure: ${chapter.chapterContent.first}");
          print("  First page URL: ${chapter.chapterContent.first.contentUrl}");
        }
      }
    }
    print("----------- END DEBUG -----------");
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _setSystemUIOverlays() {
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _setSystemUIOverlays();
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });
  }

  void _changeBrightness(double value) {
    setState(() {
      _brightness = value;
    });
  }

  void _toggleInvertColors() {
    setState(() {
      _invertColors = !_invertColors;
    });
  }

  void _changeReadingDirection(String? direction) {
    if (direction != null) {
      setState(() {
        _selectedReadingDirection = direction;
      });
    }
  }

  void _changeLayout(String? layout) {
    if (layout != null) {
      setState(() {
        _selectedLayout = layout;
      });
    }
  }

  void _changePage(int page) {
    if (!mounted) return;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (!mounted) return;

    final currentChapter = widget.comic.chapters![_currentChapterIndex];
    final pageCount = currentChapter.chapterContent.length;

    if (_currentPageIndex < pageCount - 1) {
      // Go to next page in current chapter
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentChapterIndex < widget.comic.chapters!.length - 1) {
      // Go to next chapter
      setState(() {
        _currentChapterIndex++;
        _currentPageIndex = 0;
        // Create new controller for new chapter
        _pageController = PageController(initialPage: 0);
      });
    }
  }

  void _goToPreviousPage() {
    if (!mounted) return;

    if (_currentPageIndex > 0) {
      if (_pageController.hasClients) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentChapterIndex > 0) {
      // Go to previous chapter
      setState(() {
        _currentChapterIndex--;
        _currentPageIndex =
            widget.comic.chapters![_currentChapterIndex].chapterContent.length -
            1;
        // Create new controller for new chapter
        _pageController = PageController(initialPage: _currentPageIndex);
      });
    }
  }

  // Improved method to extract content URL from page data
  String getContentUrl(ChapterContent page) {
    if (page.contentUrl.isEmpty) {
      print("Warning: Page URL is empty");
      return "https://mangadex.org/32dc232e-2387-4bc8-95b0-fba8eaa7461d";
    }
    return page.contentUrl;
  }

  // Updated method to build page image with better error handling
  Widget _buildPageImage(String url) {
    if (url.isEmpty) {
      url = "https://cuutruyen.net/img/oneshot-dayruined.5d6664b8.jpg";
      print("Debug - Using fallback URL due to empty input");
    }

    print("Debug - Loading image from URL: $url");

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      width: double.infinity,
      placeholder:
          (context, url) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF4D4FC1)),
          ),
      errorWidget: (context, url, error) {
        print("Debug - Image loading error: $error for URL: $url");
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Không thể tải trang',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 8),
              Text(
                'URL: $url',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Try opening the URL directly in browser
                  launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Mở URL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D4FC1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageView(List<ChapterContent> pages) {
    final currentChapter = widget.comic.chapters![_currentChapterIndex];
    final isLockedComic =
        widget.comic.comicId == "5" || widget.comic.comicId == "7";

    if (isLockedComic &&
        currentChapter.chapterType == 'pay' &&
        currentChapter.isLocked) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          image: DecorationImage(
            image: NetworkImage(widget.comic.coverUrl),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 72, color: Colors.orange),
                  const SizedBox(height: 24),
                  Text(
                    'Chương này chưa được mở khóa',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn cần mua chương này để tiếp tục đọc',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Giá: ${currentChapter.price.toInt()} xu',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Thêm vào giỏ hàng'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D4FC1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // Navigate directly to CartScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CartScreen(
                                args: {
                                  'comic': widget.comic,
                                  'chapter': currentChapter,
                                },
                              ),
                        ),
                      ).then((result) {
                        // If purchase was successful, refresh the page
                        if (result == true) {
                          setState(() {
                            // In a real app, this would update the lock status in the backend
                            // For demo purposes, we could update the chapter status directly
                            final updatedChapters = List.of(
                              widget.comic.chapters!,
                            );
                            updatedChapters[_currentChapterIndex] = Chapter(
                              chapterId: currentChapter.chapterId,
                              chapterName: currentChapter.chapterName,
                              createdDate: currentChapter.createdDate,
                              view: currentChapter.view,
                              chapterContent: currentChapter.chapterContent,
                              chapterType: currentChapter.chapterType,
                              price: currentChapter.price,
                              isLocked: false, // Unlock the chapter
                            );

                            widget.comic.chapters = updatedChapters;
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // For free chapters or unlocked chapters, continue with normal display
    if (pages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy nội dung chương',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D4FC1),
              ),
              child: Text('Quay lại'),
            ),
          ],
        ),
      );
    }

    // Log the first page for debugging
    print("Debug - First page in chapter: ${pages.first}");

    if (_selectedLayout == 'Continuous') {
      return ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          print("Debug - Building page at index: $index");
          final contentUrl = getContentUrl(pages[index]);
          return _buildPageImage(contentUrl);
        },
      );
    } else {
      // Only build PageView if controller is initialized
      if (!_pageController.hasClients) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4D4FC1)),
        );
      }

      return PageView.builder(
        controller: _pageController,
        reverse: _selectedReadingDirection == 'Right to Left',
        scrollDirection:
            _selectedReadingDirection == 'Vertical'
                ? Axis.vertical
                : Axis.horizontal,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final contentUrl = getContentUrl(pages[index]);
          return _buildPageImage(contentUrl);
        },
      );
    }
  }

  Widget _buildTopBarContent(Chapter chapter) {
    String chapterName = chapter.chapterName ?? "Không rõ chương";
    String comicName = widget.comic.comicName ?? "Không rõ truyện";
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  '$comicName - $chapterName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: _toggleFullScreen,
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: _toggleSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarContent(int pageCount) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slider for page navigation - only show if we have pages
            if (pageCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      pageCount > 0 ? '${_currentPageIndex + 1}' : '0',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '$pageCount',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page, color: Colors.white),
                  onPressed:
                      pageCount > 1
                          ? () {
                            setState(() {
                              _currentPageIndex = 0;
                              _pageController.jumpToPage(0);
                            });
                          }
                          : null,
                ),
                IconButton(
                  icon: const Icon(Icons.navigate_before, color: Colors.white),
                  onPressed: pageCount > 1 ? _goToPreviousPage : null,
                ),

                // Chapter dropdown - Only enable if we have chapters
                if (widget.comic.chapters != null &&
                    widget.comic.chapters!.isNotEmpty)
                  DropdownButton<int>(
                    value: _currentChapterIndex,
                    dropdownColor: Colors.black87,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    underline: Container(
                      height: 2,
                      color: const Color(0xFF4D4FC1),
                    ),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _currentChapterIndex = newValue;
                          _currentPageIndex = 0;
                          _pageController = PageController(initialPage: 0);
                        });
                      }
                    },
                    items: List.generate(
                      widget.comic.chapters!.length,
                      (index) => DropdownMenuItem<int>(
                        value: index,
                        child: Text(
                          widget.comic.chapters![index].chapterName ??
                              'Chapter ${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                IconButton(
                  icon: const Icon(Icons.navigate_next, color: Colors.white),
                  onPressed: pageCount > 1 ? _goToNextPage : null,
                ),
                IconButton(
                  icon: const Icon(Icons.last_page, color: Colors.white),
                  onPressed:
                      pageCount > 1
                          ? () {
                            final lastPageIndex = math.max(0, pageCount - 1);
                            setState(() {
                              _currentPageIndex = lastPageIndex;
                              _pageController.jumpToPage(lastPageIndex);
                            });
                          }
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    // For the credits and info section
    String comicName = widget.comic.comicName ?? "Không rõ truyện";
    String viewCount = widget.comic.view?.toString() ?? "0";
    String updateDate = "Không rõ";

    try {
      if (widget.comic.chapters != null &&
          _currentChapterIndex >= 0 &&
          _currentChapterIndex < widget.comic.chapters!.length) {
        var chapter = widget.comic.chapters![_currentChapterIndex];
        if (chapter.createdDate != null) {
          var dateStr = chapter.createdDate.toString();
          updateDate = dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
        }
      }
    } catch (e) {
      print("Error getting chapter date: $e");
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cài đặt đọc truyện',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _toggleSettings,
                ),
              ],
            ),
            const Divider(color: Colors.white30),

            // Brightness setting
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                'Độ sáng',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.brightness_low, color: Colors.white),
                Expanded(
                  child: Slider(
                    value: _brightness,
                    min: 0.1,
                    max: 2.0,
                    activeColor: const Color(0xFF4D4FC1),
                    onChanged: _changeBrightness,
                  ),
                ),
                const Icon(Icons.brightness_high, color: Colors.white),
              ],
            ),

            // Invert colors setting
            SwitchListTile(
              title: const Text(
                'Chế độ đọc đêm (đảo màu)',
                style: TextStyle(color: Colors.white),
              ),
              value: _invertColors,
              activeColor: const Color(0xFF4D4FC1),
              onChanged: (value) => _toggleInvertColors(),
            ),

            // Reading direction
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                'Hướng đọc',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              children:
                  _readingDirections.map((direction) {
                    return ChoiceChip(
                      label: Text(direction),
                      selected: _selectedReadingDirection == direction,
                      onSelected: (selected) {
                        if (selected) {
                          _changeReadingDirection(direction);
                        }
                      },
                      selectedColor: const Color(0xFF4D4FC1),
                      backgroundColor: Colors.grey.shade800,
                      labelStyle: TextStyle(
                        color:
                            _selectedReadingDirection == direction
                                ? Colors.white
                                : Colors.grey.shade300,
                      ),
                    );
                  }).toList(),
            ),

            // Layout settings
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                'Bố cục trang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              children:
                  _layouts.map((layout) {
                    return ChoiceChip(
                      label: Text(layout),
                      selected: _selectedLayout == layout,
                      onSelected: (selected) {
                        if (selected) {
                          _changeLayout(layout);
                        }
                      },
                      selectedColor: const Color(0xFF4D4FC1),
                      backgroundColor: Colors.grey.shade800,
                      labelStyle: TextStyle(
                        color:
                            _selectedLayout == layout
                                ? Colors.white
                                : Colors.grey.shade300,
                      ),
                    );
                  }).toList(),
            ),

            const Spacer(),

            // Credits and info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn đang đọc: $comicName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$viewCount lượt đọc',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cập nhật: $updateDate',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ChapterContent> pages = [];
    Chapter? chapter;

    try {
      // Check that comic has chapters and the expected format
      if (widget.comic.chapters != null && widget.comic.chapters!.isNotEmpty) {
        var chapters = widget.comic.chapters!;

        // Verify chapter index is valid
        if (_currentChapterIndex >= 0 &&
            _currentChapterIndex < chapters.length) {
          chapter = chapters[_currentChapterIndex];

          // Verify chapter_content exists and has the correct format
          if (chapter.chapterContent.isNotEmpty) {
            pages = chapter.chapterContent;
            print(
              "Found ${pages.length} pages in chapter $_currentChapterIndex",
            );
          } else {
            print(
              "Warning: No chapter_content found in chapter $_currentChapterIndex",
            );
          }
        } else {
          print("Warning: Invalid chapter index: $_currentChapterIndex");
        }
      } else {
        print("Warning: Comic has no chapters or invalid chapter data");
      }
    } catch (e) {
      print("Error accessing comic data: $e");
      // Show error dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Lỗi dữ liệu"),
                content: const Text(
                  "Không thể tải nội dung truyện. Vui lòng thử lại sau.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Đóng"),
                  ),
                ],
              ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Main content
            ColorFiltered(
              colorFilter: ColorFilter.matrix(
                _invertColors
                    ? [
                      -1,
                      0,
                      0,
                      0,
                      255,
                      0,
                      -1,
                      0,
                      0,
                      255,
                      0,
                      0,
                      -1,
                      0,
                      255,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]
                    : [
                      _brightness,
                      0,
                      0,
                      0,
                      0,
                      0,
                      _brightness,
                      0,
                      0,
                      0,
                      0,
                      0,
                      _brightness,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ],
              ),
              child: _buildPageView(pages),
            ),

            // Controls and overlays
            if (_showControls) ...[
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBarContent(chapter!),
              ),

              // Bottom bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBarContent(pages.length),
              ),
            ],

            // Settings panel
            if (_showSettings) _buildSettingsPanel(),
          ],
        ),
      ),
    );
  }
}
