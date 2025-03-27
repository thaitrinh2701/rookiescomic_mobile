import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/components/loader.dart';
import 'package:rookiescomic_mobile/models/comics.dart' as comics_model;
import 'package:rookiescomic_mobile/widgets/top_comics_slider.dart';
import 'package:rookiescomic_mobile/apis/comics_api.dart';

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
    return FutureBuilder<List<Map<String, String>>>(
      future: () async {
        final comics = await fetchTopMonthComics(limit: 4);
        return comics
            .map(
              (comic) =>
                  comic.toJson().map((k, v) => MapEntry(k, v.toString())),
            )
            .toList();
      }(),
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
