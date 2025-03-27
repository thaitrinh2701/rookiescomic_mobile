import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:rookiescomic_mobile/models/comics.dart'; // Add this import
import 'comic_detail_page.dart';


class AllComicsListPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> comics; // Changed from Map<String, String>

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

    // Filter and sort comics based on search query and sort option
    final filteredComics =
        widget.comics
            .where(
              (comic) => (comic["comic_name"] ?? '').toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();

    // Sort comics based on selected option
    switch (_selectedSortOption) {
      case 'newest':
        filteredComics.sort(
          (a, b) =>
              (b["created_date"] ?? '').compareTo(a["created_date"] ?? ''),
        );
        break;
      case 'oldest':
        filteredComics.sort(
          (a, b) =>
              (a["created_date"] ?? '').compareTo(b["created_date"] ?? ''),
        );
        break;
      case 'popularity':
        filteredComics.sort((a, b) {
          final viewA = int.tryParse(a["view"] ?? '0') ?? 0;
          final viewB = int.tryParse(b["view"] ?? '0') ?? 0;
          return viewB.compareTo(viewA);
        });
        break;
      case 'alphabetical':
        filteredComics.sort(
          (a, b) => (a["comic_name"] ?? '').compareTo(b["comic_name"] ?? ''),
        );
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchBar(),
          _buildSortFilter(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver:
                filteredComics.isEmpty
                    ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy truyện nào',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildComicCard(filteredComics[index]),
                        ),
                        childCount: filteredComics.length,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      stretch: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        titlePadding: const EdgeInsets.only(left: 50, bottom: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, accentColor],
                ),
              ),
            ),
            // Add subtle pattern overlay
            Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/cartographer.png',
                fit: BoxFit.cover,
              ),
            ),
            // Add a bottom fade effect
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, primaryColor.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Tìm truyện...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                    : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSortOption('newest', 'Mới nhất'),
              _buildSortOption('oldest', 'Cũ nhất'),
              _buildSortOption('popularity', 'Phổ biến'),
              _buildSortOption('alphabetical', 'A-Z'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    final isSelected = _selectedSortOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortOption = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _getSortIcon(value),
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(String sortOption) {
    switch (sortOption) {
      case 'newest':
        return Icons.calendar_today;
      case 'oldest':
        return Icons.history;
      case 'popularity':
        return Icons.trending_up;
      case 'alphabetical':
        return Icons.sort_by_alpha;
      default:
        return Icons.sort;
    }
  }

  // Fix the formatDate method to handle both String and DateTime inputs
  String formatDate(dynamic dateInput) {
    if (dateInput == null) return 'Unknown date';

    try {
      DateTime date;
      if (dateInput is String) {
        date = DateTime.parse(dateInput);
      } else if (dateInput is DateTime) {
        date = dateInput;
      } else {
        return 'Invalid date';
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildComicCard(Map<String, dynamic> comic) {
    final String imageUrl = comic["cover_url"]?.toString() ?? "";
    final String title = comic["comic_name"]?.toString() ?? "Không có tên";
    final String description =
        comic["description"]?.toString() ?? "Hiện không có mô tả";
    final String chapCount = comic["quantity_chap"]?.toString() ?? "0";
    final String views = comic["view"]?.toString() ?? "0";
    final String genre = comic["genres_id"]?.toString() ?? "unknown";

    // Map genre IDs to display names
    final Map<String, Map<String, dynamic>> genreMap = {
      "action": {"name": "Hành động", "color": const Color(0xFFE53935)},
      "comedy": {"name": "Hài hước", "color": const Color(0xFFFFB300)},
      "mystery": {"name": "Bí ẩn", "color": const Color(0xFF7B1FA2)},
      "adventure": {"name": "Phiêu lưu", "color": const Color(0xFF43A047)},
      "sci-fi": {"name": "Viễn tưởng", "color": const Color(0xFF1E88E5)},
      "romance": {"name": "Tình cảm", "color": const Color(0xFFEC407A)},
      "sports": {"name": "Thể thao", "color": const Color(0xFF039BE5)},
      "unknown": {"name": "Khác", "color": Colors.grey},
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ComicDetailPage(
                  comic: Comic.fromJson(comic), // Convert Map to Comic
                ),
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

            // Comic cover with gradient overlay
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'comic_image_${comic["comic_id"]}',
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 110,
                      height: 160,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                            ),
                          ),
                    ),
                  ),
                  // Genre tag at top
                  Positioned(
                    top: 8,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: genreMap[genre]?["color"] ?? Colors.grey,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        genreMap[genre]?["name"] ?? "Khác",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Stats at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            views,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Comic info

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

                    const SizedBox(height: 4),
                    // Description
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Stats row at bottom
                    Row(
                      children: [
                        // Chapters count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.book, size: 12, color: primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                "$chapCount chương",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Date
                        Text(
                          formatDate(comic["created_date"]),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        // Read now button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Đọc ngay",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
