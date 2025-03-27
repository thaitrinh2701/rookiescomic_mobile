import 'package:flutter/material.dart';

import 'package:rookiescomic_mobile/models/comics.dart' as comics_model;
import 'package:rookiescomic_mobile/pages/comic_detail_page.dart';
import 'package:rookiescomic_mobile/screens/search_screen.dart';
import 'package:rookiescomic_mobile/widgets/below_comics.dart';
import 'package:rookiescomic_mobile/widgets/top_comics.dart';
import 'package:rookiescomic_mobile/apis/comics_api.dart';

class ComicScreen extends StatefulWidget {
  const ComicScreen({super.key});

  @override
  State<ComicScreen> createState() => _ComicsScreenState();
}

class _ComicsScreenState extends State<ComicScreen> {
  // Methods to fetch comics
  Future<List<Map<String, dynamic>>> fetchTopComicOfWeek({
    required int limit,
  }) async {
    // Call the imported function
    return comics_model.getTopComicOfWeek(limit: limit);
  }

  Future<List<Map<String, dynamic>>> fetchTopComicOfMonth({
    required int limit,
  }) async {
    // Call the imported function
    return comics_model.getTopComicOfMonth(limit: limit);
  }

  void _navigateToDetail(dynamic comic) {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ComicDetailPage(
              comic: comics_model.Comic.fromJson(comic as Map<String, dynamic>),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rookies Comic'),
        toolbarHeight: 60,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 70),

            const SizedBox(height: 350, child: TopComicList()),

            const SizedBox(height: 30),

            SizedBox(
              height: 275,
              child: ComicList(
                fetchComic: () async {
                  final comics = await fetchTopWeekComics(limit: 4);
                  return comics
                      .take(4)
                      .map((comic) => comic.toStringMap())
                      .toList();
                },

                title: " Truyện hot tuần 🔥",
                onTapComic: _navigateToDetail,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 275,
              child: ComicList(
                fetchComic: () async {
                  final comics = await fetchTopMonthComics(limit: 4);
                  return comics
                      .take(4)
                      .map((comic) => comic.toStringMap())
                      .toList();
                },

                title: " Truyện hot tháng 🔥",
                onTapComic: _navigateToDetail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
