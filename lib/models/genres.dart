class Genre {
  final String genresId;
  final String genresName;
  final String genresDescription;
  final int status;

  Genre({
    required this.genresId,
    required this.genresName,
    required this.genresDescription,
    required this.status,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      genresId: json['genresId'] ?? json['genres_id'] ?? '',
      genresName: json['genresName'] ?? json['genres_name'] ?? '',
      genresDescription:
          json['genresDescription'] ?? json['genres_description'] ?? '',
      status: int.tryParse(json['status']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "genres_id": genresId,
      "genres_name": genresName,
      "genres_description": genresDescription,
      "status": status,
    };
  }

  @override
  String toString() => genresName;
}
