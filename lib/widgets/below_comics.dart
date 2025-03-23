import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/components/loader.dart';
import 'package:rookiescomic_mobile/widgets/below_comics_slider.dart';

class ComicList extends StatelessWidget {
  final Future<List<Map<String, String>>> Function() fetchComic;
  final String title;
  final Function(Map<String, String>) onTapComic;

  const ComicList({
    super.key,
    required this.fetchComic,
    required this.title,
    required this.onTapComic,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: fetchComic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        if (snapshot.hasError) {
          return Text('Error: \${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Hiện không có truyện");
        }

        final comics = snapshot.data!;
        return ComicSlider(
          comics: comics,
          title: title,
          onTapComic: onTapComic,
        );
      },
    );
  }
}
