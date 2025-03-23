import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/models/comics.dart';
import 'package:rookiescomic_mobile/pages/comic_detail_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allComics = []; // lấy truyện từ API
  List<Map<String, dynamic>> filteredComics = []; // lấy truyện lọc
  bool isLoading = false;
  bool hasSearched =
      false; // kiểm tra search chưa, để có gì đổi lại giá trị khi người ta bấm nút search lại

  @override
  void initState() {
    super.initState();
    _fetchAllComics(); // Load tất cả truyện một lần khi mở trang, để đỡ bị sida
  }

  Future<void> _fetchAllComics() async {
    setState(() => isLoading = true);
    try {
      allComics = await getAllComics(); // API lấy danh sách chuyện
    } catch (e) {
      print("Error fetching comics: $e");
    }
    setState(() => isLoading = false);
  }

  void _filterComics(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredComics = [];
        hasSearched = false;
      });
      return;
    }

    setState(() {
      hasSearched = true;
      filteredComics =
          allComics
              .where(
                (comic) => comic["comic_name"]!.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm Comic...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _filterComics, // Gợi ý ngay khi nhập, fill liền
            ),
          ),
          // Hiển thị Gợi ý
          Expanded(
            child:
                filteredComics.isEmpty && hasSearched
                    ? const Center(
                      child: Text("Hiện không có truyện này"),
                    ) // Không có kết quả
                    : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: filteredComics.length,
                      itemBuilder: (context, index) {
                        final comic = filteredComics[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              comic["cover_url"] ?? "",
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50),
                            ),
                          ),
                          title: Text(comic["comic_name"] ?? "Unknown"),
                          subtitle: Text(
                            comic["description"] ?? "Không có mô tả",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ComicDetailPage(comic: comic),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
