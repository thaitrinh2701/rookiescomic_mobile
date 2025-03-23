import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/models/comics.dart';
import 'package:rookiescomic_mobile/pages/comic_detail_page.dart';
import 'package:rookiescomic_mobile/widgets/below_comics.dart';
import 'package:rookiescomic_mobile/widgets/top_comics.dart';

class ComicScreen extends StatefulWidget {
  const ComicScreen({super.key});

  @override
  State<ComicScreen> createState() => _ComicsScreenState();
}

class _ComicsScreenState extends State<ComicScreen> {
  void _navigateToDetail(Map<String, String> comics) {
    if (!mounted) return;
    if (comics.isEmpty) {
      print("Error: Comic data is empty!");
      return;
    }

    Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComicDetailPage(comic: comics),
          ),
        )
        .then((_) {
          print("Returned from detail page");
        })
        .catchError((e) {
          print("Navigation error: $e");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rookies Comic'),
        toolbarHeight: 60,
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const SearchScreen()),
          //     );
          //   },
          //   icon: const Icon(Icons.search),
          // ),
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
                fetchComic: () => getTopComicOfWeek(limit: 4),
                title: " Truyện hot tuần 🔥",
                onTapComic: _navigateToDetail,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 275,
              child: ComicList(
                fetchComic: () => getTopComicOfMonth(limit: 4),
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
