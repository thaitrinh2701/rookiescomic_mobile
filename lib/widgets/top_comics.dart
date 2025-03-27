import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/components/loader.dart';
import 'package:rookiescomic_mobile/models/comics.dart' as comics_model;
import 'package:rookiescomic_mobile/widgets/top_comics_slider.dart';

class TopComicList extends StatelessWidget {
  const TopComicList({super.key});

  Future<List<Map<String, dynamic>>> fetchFeatureComic({
    required String rankingType,
    required int limit,
  }) async {
    return comics_model.getFeatureComic(rankingType: rankingType, limit: limit);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchFeatureComic(rankingType: 'all', limit: 4),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No comics available");
        }

        final comics = snapshot.data!;
        return TopComicImageSlider(comics: comics);
      },
    );
  }
}
