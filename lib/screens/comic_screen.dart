import 'package:flutter/material.dart';
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
      print("Error: Manga data is empty!");
      return;
    }

    // Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => MangaDetailPage(manga: manga),
    //       ),
    //     )
    //     .then((_) {
    //       print("Returned from detail page");
    //     })
    //     .catchError((e) {
    //       print("Navigation error: $e");
    //     });
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
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const SearchPage()),
              // );
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

            // SizedBox(
            //   height: 240,
            //   child: MangaList(
            //     fetchManga: () => getTopMangaOfWeek(limit: 4),
            //     title: "Comics of the Week",
            //     onTapManga: _navigateToDetail,
            //   ),
            // ),

            // const SizedBox(height: 25),

            // SizedBox(
            //   height: 240,
            //   child: MangaList(
            //     fetchManga: () => getTopMangaOfMonth(limit: 4),
            //     title: "Comics of the Month",
            //     onTapManga: _navigateToDetail,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
