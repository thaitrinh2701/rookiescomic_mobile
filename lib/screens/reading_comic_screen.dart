import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math; // Add import for math.max function

class ReadingComicScreen extends StatefulWidget {
  final Map<String, dynamic> comic;
  final int initialChapterIndex;
  final int initialPageIndex;

  const ReadingComicScreen({
    super.key,
    required this.comic,
    this.initialChapterIndex = 0,
    this.initialPageIndex = 0,
  });

  @override
  State<ReadingComicScreen> createState() => _ReadingComicScreenState();
}

class _ReadingComicScreenState extends State<ReadingComicScreen> {
  late final PageController _pageController;
  late int _currentChapterIndex;
  late int _currentPageIndex;
  bool _isFullScreen = false;
  bool _showControls = true;
  bool _showSettings = false;
  double _brightness = 1.0;
  bool _invertColors = false;

  // Reading direction options - TRÊN XUỐNG - TRÁI PHẢI CÁC THỨ
  final List<String> _readingDirections = [
    'Vertical',
    'Left to Right',
    'Right to Left',
  ];
  String _selectedReadingDirection = 'Vertical';

  // LAYOUT CỦA PAGE
  final List<String> _layouts = ['Single Page', 'Double Page', 'Continuous'];
  String _selectedLayout = 'Continuous';

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _currentPageIndex = widget.initialPageIndex;
    _pageController = PageController(initialPage: _currentPageIndex);

    _setSystemUIOverlays();
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

  void _goToNextPage() {
    final currentChapter = widget.comic['chapters'][_currentChapterIndex];
    final pageCount = currentChapter['chapter_content'].length;

    if (_currentPageIndex < pageCount - 1) {
      // Go to next page in current chapter
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentChapterIndex < widget.comic['chapters'].length - 1) {
      // Go to next chapter
      setState(() {
        _currentChapterIndex++;
        _currentPageIndex = 0;
        _pageController = PageController(initialPage: 0);
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      // Go to previous page in current chapter
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentChapterIndex > 0) {
      // Go to previous chapter
      setState(() {
        _currentChapterIndex--;
        final previousChapter = widget.comic['chapters'][_currentChapterIndex];
        _currentPageIndex = previousChapter['chapter_content'].length - 1;
        _pageController = PageController(initialPage: _currentPageIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe access to chapters and content with null and type checking
    List<dynamic> chapters = [];
    Map<String, dynamic> chapter = {};
    List<dynamic> pages = [];

    // GET CHAPTER
    if (widget.comic['chapters'] is List) {
      chapters = widget.comic['chapters'] as List;

      if (_currentChapterIndex >= 0 && _currentChapterIndex < chapters.length) {
        if (chapters[_currentChapterIndex] is Map<String, dynamic>) {
          chapter = chapters[_currentChapterIndex] as Map<String, dynamic>;

          // LẤY PAGES
          if (chapter['chapter_content'] is List) {
            pages = chapter['chapter_content'] as List;
          } else {
            // KHI CHAPTER KHÔNG PHẢI LÀ LIST
            pages = [];
            print("Warning: chapter_content is not a list or is null");
          }
        } else {
          print("Warning: chapter at index $_currentChapterIndex is not a Map");
        }
      } else {
        print("Warning: Invalid chapter index: $_currentChapterIndex");
      }
    } else {
      print("Warning: comic.chapters is not a List or is null");
    }

    final int pageCount = pages.length;

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
                      -1, 0, 0, 0, 255, //
                      0, -1, 0, 0, 255, //
                      0, 0, -1, 0, 255, //
                      0, 0, 0, 1, 0, //
                    ]
                    : [
                      _brightness, 0, 0, 0, 0, //
                      0, _brightness, 0, 0, 0, //
                      0, 0, _brightness, 0, 0, //
                      0, 0, 0, 1, 0, //
                    ],
              ),
              child: _buildPageView(pages),
            ),

            // Top controls (AppBar)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child:
                  _showControls
                      ? _buildTopBar(chapter)
                      : const SizedBox.shrink(),
            ),

            // Bottom navigation controls
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child:
                  _showControls
                      ? _buildBottomBar(pageCount)
                      : const SizedBox.shrink(),
            ),

            // Settings panel
            AnimatedOpacity(
              opacity: _showSettings ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child:
                  _showSettings
                      ? _buildSettingsPanel()
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView(List<dynamic> pages) {
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

    if (_selectedLayout == 'Continuous') {
      return ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          String contentUrl = "";

          // Safely extract content_url based on actual data structure
          if (page is Map) {
            contentUrl = page['content_url']?.toString() ?? "";
          } else if (page is String) {
            contentUrl = page; // If the page itself is the URL
          }

          return _buildPageImage(contentUrl);
        },
      );
    } else {
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
          final page = pages[index];
          String contentUrl = "";

          // Safely extract content_url based on actual data structure
          if (page is Map) {
            contentUrl = page['content_url']?.toString() ?? "";
          } else if (page is String) {
            contentUrl = page; // If the page itself is the URL
          }

          return _buildPageImage(contentUrl);
        },
      );
    }
  }

  Widget _buildPageImage(String url) {
    // Replace blob URLs with placeholders for demo purposes
    final imageUrl =
        url.startsWith('blob:')
            ? 'https://via.placeholder.com/800x1200/4D4FC1/FFFFFF?text=Comic+Page'
            : url;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      placeholder:
          (context, url) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF4D4FC1)),
          ),
      errorWidget:
          (context, url, error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải trang',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                TextButton(onPressed: () {}, child: const Text('Thử lại')),
              ],
            ),
          ),
    );
  }

  Widget _buildTopBar(Map<String, dynamic> chapter) {
    String chapterName =
        chapter['chapter_name']?.toString() ?? "Không rõ chương";
    String comicName =
        widget.comic['comic_name']?.toString() ?? "Không rõ truyện";

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
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
      ),
    );
  }

  Widget _buildBottomBar(int pageCount) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
                      Expanded(
                        child: Slider(
                          value: _currentPageIndex.toDouble(),
                          min: 0,
                          max: math.max(
                            0.0,
                            (pageCount - 1).toDouble(),
                          ), // Ensure max is never less than min
                          divisions: math.max(
                            1,
                            pageCount - 1,
                          ), // Ensure divisions is at least 1
                          activeColor: const Color(0xFF4D4FC1),
                          inactiveColor: Colors.grey.shade700,
                          onChanged:
                              pageCount >
                                      1 // Only allow changes if we have multiple pages
                                  ? (value) {
                                    setState(() {
                                      _currentPageIndex = value.toInt();
                                      _pageController.jumpToPage(
                                        _currentPageIndex,
                                      );
                                    });
                                  }
                                  : null,
                        ),
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
                    icon: const Icon(
                      Icons.navigate_before,
                      color: Colors.white,
                    ),
                    onPressed: pageCount > 1 ? _goToPreviousPage : null,
                  ),

                  // Chapter dropdown - Only enable if we have chapters
                  if (widget.comic['chapters'] != null &&
                      widget.comic['chapters'] is List &&
                      (widget.comic['chapters'] as List).isNotEmpty)
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
                        (widget.comic['chapters'] as List).length,
                        (index) => DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            widget.comic['chapters'][index]['chapter_name'] ??
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
      ),
    );
  }

  Widget _buildSettingsPanel() {
    // For the credits and info section
    String comicName =
        widget.comic['comic_name']?.toString() ?? "Không rõ truyện";
    String viewCount = widget.comic['view']?.toString() ?? "0";
    String updateDate = "Không rõ";

    try {
      if (widget.comic['chapters'] is List &&
          _currentChapterIndex >= 0 &&
          _currentChapterIndex < (widget.comic['chapters'] as List).length) {
        var chapter = widget.comic['chapters'][_currentChapterIndex];
        if (chapter is Map && chapter['created_date'] != null) {
          var dateStr = chapter['created_date'].toString();
          updateDate = dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
        }
      }
    } catch (e) {
      print("Error getting chapter date: $e");
    }

    return Positioned.fill(
      child: Container(
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
      ),
    );
  }
}
