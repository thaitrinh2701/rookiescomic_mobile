import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/models/comics.dart';
import 'package:rookiescomic_mobile/pages/comic_detail_page.dart';
import 'package:rookiescomic_mobile/apis/comics_api.dart';
import 'package:rookiescomic_mobile/utils/image_sort_utils.dart'; // nếu bạn dùng formatDate

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Color primaryColor = const Color(0xFF4D4FC1);
  final Color backgroundColor = const Color(0xFFF8F9FA);

  String selectedGenre = "all";
  bool isLoading = true;
  List<Map<String, String>> comicsData = [];

  final List<Map<String, dynamic>> genres = [
    {"id": "all", "name": "Tất cả", "color": Color(0xFF4D4FC1)},
    {"id": "action", "name": "Hành động", "color": Color(0xFFE53935)},
    {"id": "comedy", "name": "Hài hước", "color": Color(0xFFFFB300)},
    {"id": "mystery", "name": "Bí ẩn", "color": Color(0xFF7B1FA2)},
    {"id": "adventure", "name": "Phiêu lưu", "color": Color(0xFF43A047)},
    {"id": "sci-fi", "name": "Viễn tưởng", "color": Color(0xFF1E88E5)},
    {"id": "romance", "name": "Tình cảm", "color": Color(0xFFEC407A)},
    {"id": "sports", "name": "Thể thao", "color": Color(0xFF039BE5)},
  ];

  @override
  void initState() {
    super.initState();
    _loadComics();
  }

  Future<void> _loadComics() async {
    setState(() => isLoading = true);

    try {
      List<Comic> comics;

      if (selectedGenre == "all") {
        comics = await fetchAllComics();
      } else {
        comics = await fetchComicsByGenresName(selectedGenre);
      }

      setState(() {
        comicsData = comics.map((comic) => comic.toStringMap()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading comics: $e");
      setState(() => isLoading = false);
    }
  }

  String getGenreName(String genreId) {
    final genre = genres.firstWhere(
      (g) => g["id"] == genreId,
      orElse: () => {"name": "Khác"},
    );
    return genre["name"];
  }

  Color getGenreColor(String genreId) {
    final genre = genres.firstWhere(
      (g) => g["id"] == genreId,
      orElse: () => {"color": primaryColor},
    );
    return genre["color"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Thể loại truyện tranh'),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Column(
        children: [
          _buildGenreFilter(),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : comicsData.isEmpty
                    ? _buildEmptyState()
                    : _buildComicGrid(comicsData),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children:
            genres.map((genre) {
              final isSelected = selectedGenre == genre["id"];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    genre["name"],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: genre["color"],
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      selectedGenre = genre["id"];
                    });
                    _loadComics();
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy truyện cho thể loại này',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                selectedGenre = "all";
              });
              _loadComics();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Xem tất cả thể loại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComicGrid(List<Map<String, String>> comics) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: comics.length,
      itemBuilder: (context, index) {
        final comic = comics[index];
        final genreId = comic["genres_id"] ?? "unknown";

        return GestureDetector(
          onTap: () {
            final processedComic = {
              "comic_id": comic["comic_id"],
              "comic_name": comic["comic_name"],
              "cover_url": comic["cover_url"],
              "user_id": comic["user_id"],
              "created_date": comic["created_date"],
              "quantity_chap": comic["quantity_chap"],
              "description": comic["description"],
              "status": comic["status"],
              "view": comic["view"],
              "genres_id": comic["genres_id"],
            };

            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ComicDetailPage(comic: Comic.fromJson(processedComic)),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        comic["cover_url"] ?? "",
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (ctx, error, stackTrace) => Container(
                              height: 180,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getGenreColor(genreId),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            getGenreName(genreId),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comic["comic_name"] ?? "Unknown Title",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDate(comic["created_date"]),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
