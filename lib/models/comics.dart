import 'package:rookiescomic_mobile/models/users.dart';
import 'chapter.dart';

class Comic {
  final String comicId;
  final String comicName;
  final String coverUrl;
  final String userId;
  final DateTime createdDate;
  final int quantityChap;
  final String description;
  final int status;
  final int view;
  final String genresId;
  final User? user;
  List<Chapter>? chapters;

  String get posterName {
    if (user != null) {
      return "${user!.firstName} ${user!.lastName}";
    }
    return "Không rõ";
  }

  Comic({
    required this.comicId,
    required this.comicName,
    required this.coverUrl,
    required this.userId,
    required this.createdDate,
    required this.quantityChap,
    required this.description,
    required this.status,
    required this.view,
    required this.genresId,
    required this.user,
    this.chapters,
  });

  // Convert JSON sang object
  factory Comic.fromJson(Map<String, dynamic> json) {
    // Handle missing user_id
    String userId = '';
    if (json["user_id"] != null) {
      userId = json["user_id"].toString();
    }

    // Handle created_date
    DateTime createdDate;
    try {
      if (json["created_date"] is DateTime) {
        createdDate = json["created_date"];
      } else if (json["created_date"] != null) {
        createdDate = DateTime.parse(json["created_date"].toString());
      } else {
        createdDate = DateTime.now();
      }
    } catch (e) {
      createdDate = DateTime.now();
    }

    return Comic(
      comicId: json["comicId"] ?? json["comic_id"] ?? "",
      comicName: json["comicName"] ?? json["comic_name"] ?? "",
      coverUrl: json["coverUrl"] ?? json["cover_url"] ?? "",
      userId: json["userId"] ?? json["user_id"] ?? "",
      createdDate:
          DateTime.tryParse(
            json["createdDate"] ?? json["created_date"] ?? "",
          ) ??
          DateTime.now(),
      quantityChap:
          int.tryParse(
            json["quantityChap"]?.toString() ??
                json["quantity_chap"]?.toString() ??
                "0",
          ) ??
          0,
      description: json["description"] ?? "",
      status: int.tryParse(json["status"]?.toString() ?? "0") ?? 0,
      view: int.tryParse(json["view"]?.toString() ?? "0") ?? 0,
      genresId: json["genresId"] ?? json["genres_id"] ?? "",
      user: json["user"] != null ? User.fromJson(json["user"]) : null,
    );
  }

  // Convert object sang JSON
  Map<String, dynamic> toJson() {
    return {
      "comic_id": comicId,
      "comic_name": comicName,
      "cover_url": coverUrl,
      "user_id": userId,
      "poster_name": user?.fullName ?? "",
      "created_date": createdDate.toIso8601String(),
      "quantity_chap": quantityChap,
      "description": description,
      "status": status,
      "view": view,
      "genres_id": genresId,
      "chapters": chapters?.map((c) => c.toJson()).toList(),
    };
  }

  Map<String, String> toStringMap() {
    return toJson().map((key, value) => MapEntry(key, value.toString()));
  }
}

// Future<List<Map<String, dynamic>>> fetchAllComics() async {
//   await Future.delayed(Duration(seconds: 1)); // Giả lập tải dữ liệu

//   return [
//     {
//       "comic_id": "1",
//       "comic_name": "Cyberpunk Edgerunners",
//       "cover_url":
//           "https://mangadex.org/covers/832692d3-11c7-49a1-aca4-deabdcf9e996/5f48bd6a-f0bf-4b89-91b3-59ff3bc0e5c2.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(
//         Duration(days: 2),
//       ), // 2 ngày trước
//       "quantity_chap": 12,
//       "description":
//           "Một câu chuyện không thể bỏ lỡ! Tiền truyện của Cyberpunk: Edgerunners đã xuất hiện! Bộ manga gốc kể về hai anh em Pilar và Rebecca đã chính thức bắt đầu... Đây là câu chuyện về hai anh em chạy khắp Night City để tạo dựng danh tiếng của mình như những Edgerunners...",
//       "status": 1,
//       "view": 7000,
//       "genres_id": "action",
//     },
//     {
//       "comic_id": "2",
//       "comic_name": "Spy x Family",
//       "cover_url":
//           "https://mangadex.org/covers/6b958848-c885-4735-9201-12ee77abcb3c/d8babd13-5736-4964-8963-b444a950d539.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(
//         Duration(days: 5),
//       ), // 5 ngày trước
//       "quantity_chap": 25,
//       "description":
//           "Một bộ truyện hài hành động về một gia đình giả bao gồm một điệp viên, một sát thủ và một nhà ngoại cảm! Điệp viên hàng đầu Twilight là bậc thầy trong việc trà trộn vào các nhiệm vụ nguy hiểm. Nhưng khi anh nhận được nhiệm vụ bất khả thi nhất—kết hôn và có con—có lẽ lần này anh đã gặp phải thử thách quá sức mình!",
//       "status": 1,
//       "view": 5000,
//       "genres_id": "comedy",
//     },
//     {
//       "comic_id": "3",
//       "comic_name": "Touhou Chireikiden: Hansoku Tantei Satori",
//       "cover_url":
//           "https://mangadex.org/covers/f4fa3679-6918-4684-bcb6-377c9f336898/31d5e78e-a8f2-44fd-b1b0-94828a4f7fd4.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(
//         Duration(days: 10),
//       ), // 10 ngày trước
//       "quantity_chap": 15,
//       "description":
//           "Bộ manga chính thức thứ năm của Touhou, được viết bởi ZUN và ban đầu được vẽ bởi Ginmokusei. Câu chuyện theo chân Satori Komeiji trong vai trò thám tử, giải quyết những bí ẩn trong thế giới Gensokyo.",
//       "status": 1,
//       "view": 6500,
//       "genres_id": "mystery",
//     },
//     {
//       "comic_id": "4",
//       "comic_name": "Lycoris Recoil",
//       "cover_url":
//           "https://mangadex.org/covers/9c21fbcd-e22e-4e6d-8258-7d580df9fc45/0184636a-f44c-4073-9b55-435120755e47.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(
//         Duration(days: 20),
//       ), // 20 ngày trước
//       "quantity_chap": 20,
//       "description":
//           "Takina Inoue, một nữ sinh trung học là thành viên của nhóm sát thủ toàn nữ 'Lycoris', bị kỷ luật vì chống lệnh để cứu đồng đội. Cô được chuyển đến làm việc với đặc vụ Lycoris xuất sắc Chisato Nishikigi tại một chi nhánh hoạt động dưới vỏ bọc quán cà phê 'LycoReco'.",
//       "status": 1,
//       "view": 7200,
//       "genres_id": "action",
//     },
//     {
//       "comic_id": "5",
//       "comic_name": "Houkago Bokura wa Uchuu ni Madou",
//       "cover_url":
//           "https://mangadex.org/covers/91a2e0c9-cd81-4bf7-b5f7-bb37434bf6b3/7a41b522-5383-422b-b6b4-fc2007f5c603.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(
//         Duration(days: 28),
//       ), // 28 ngày trước
//       "quantity_chap": 10,
//       "description":
//           "Câu chuyện tình yêu bùng cháy như một vụ nổ tên lửa! Đội Kinoshima Rocketry vô tình khiến một thành viên trong nhóm trở nên nổi tiếng khi video thử nghiệm động cơ của họ phát nổ. Trong khi Ayame Madoi thấy chuyện này kỳ lạ, cô lại hy vọng người mà cô thích cũng sẽ để ý đến mình...",
//       "status": 1,
//       "view": 4800,
//       "genres_id": "sci-fi",
//     },
//     {
//       "comic_id": "6",
//       "comic_name": "Pocket Monsters: Liko's Treasure",
//       "cover_url":
//           "https://mangadex.org/covers/39c2752b-0d08-4bdc-8f99-4ac273fd194a/10f54e15-fda6-41c5-ae68-62d3de25dd71.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(
//         Duration(days: 33),
//       ), // 33 ngày trước
//       "quantity_chap": 8,
//       "description":
//           "Liko là một cô gái sở hữu mặt dây chuyền bí ẩn. Cô rất vui khi nhận được Pokémon đầu tiên của mình, Sprigatito, nhưng Sprigatito lại không chịu nghe lời cô chút nào...! Đây là manga chính thức kể về cuộc phiêu lưu của Liko và Sprigatito.",
//       "status": 1,
//       "view": 5300,
//       "genres_id": "adventure",
//     },
//     {
//       "comic_id": "7",
//       "comic_name": "Attack on Titan",
//       "cover_url":
//           "https://mangadex.org/covers/304ceac3-8cdb-4fe7-acf7-2b6ff7a60613/29f82b1d-b37f-455a-b630-e42bccb1422a.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(
//         Duration(days: 50),
//       ), // 50 ngày trước
//       "quantity_chap": 139,
//       "description":
//           "Hàng trăm năm trước, nhân loại suýt bị tuyệt chủng bởi Titan—những sinh vật khổng lồ chuyên ăn thịt người. Sống sót bên trong những bức tường khổng lồ, con người nghĩ rằng họ an toàn... cho đến ngày một Titan cao 60 mét phá vỡ bức tường ngoài cùng.",
//       "status": 1,
//       "view": 20000,
//       "genres_id": "action",
//     },
//     {
//       "comic_id": "8",
//       "comic_name": "One Piece",
//       "cover_url":
//           "https://mangadex.org/covers/a1c7c817-4e59-43b7-9365-09675a149a6f/249fa95b-2214-4ae3-a8f7-77338fe34542.png",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(Duration(days: 70)),
//       "quantity_chap": 1100,
//       "description":
//           "Một cuộc phiêu lưu hải tặc vĩ đại theo chân Luffy và băng Mũ Rơm trên hành trình tìm kiếm kho báu One Piece.",
//       "status": 1,
//       "view": 50000,
//       "genres_id": "adventure",
//     },
//     {
//       "comic_id": "9",
//       "comic_name": "Your Name",
//       "cover_url":
//           "https://mangadex.org/covers/c071276e-abd4-4711-8b14-544431eb152a/d6860e8a-d13e-49d8-a6ad-1fa87f937a7a.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(Duration(days: 15)),
//       "quantity_chap": 10,
//       "description":
//           "Hai người xa lạ tỉnh dậy trong cơ thể của nhau, bị cuốn vào một câu chuyện tình yêu kỳ diệu vượt thời gian.",
//       "status": 1,
//       "view": 15000,
//       "genres_id": "romance",
//     },
//     {
//       "comic_id": "10",
//       "comic_name": "Blue Lock",
//       "cover_url":
//           "https://mangadex.org/covers/4141c5dc-c525-4df5-afd7-cc7d192a832f/92943ee9-92c3-43f9-96e2-d73515ace108.jpg",
//       "user_id": "admin",
//       "created_date": DateTime.now().subtract(Duration(days: 3)),
//       "quantity_chap": 30,
//       "description":
//           "Một cuộc thi khốc liệt để tìm ra tiền đạo xuất sắc nhất Nhật Bản, quyết định tương lai của bóng đá nước này.",
//       "status": 1,
//       "view": 18000,
//       "genres_id": "sports",
//     },
//   ];
// }

// **Lấy top truyện theo tuần (7 ngày)**
// Future<List<Map<String, String>>> getTopComicOfWeek({
//   required int limit,
// }) async {
//   List<Map<String, dynamic>> allManga = await fetchAllComics();
//   DateTime now = DateTime.now();
//   DateTime oneWeekAgo = now.subtract(Duration(days: 7));

//   List<Map<String, dynamic>> filteredManga =
//       allManga
//           .where((manga) => manga["created_date"].isAfter(oneWeekAgo))
//           .toList()
//         ..sort((a, b) => b["view"].compareTo(a["view"]));

//   return filteredManga
//       .take(limit)
//       .map(
//         (manga) => manga.map((key, value) => MapEntry(key, value.toString())),
//       )
//       .toList();
// }

// // **Lấy top truyện theo tháng (30 ngày)**
// Future<List<Map<String, String>>> getTopComicOfMonth({
//   required int limit,
// }) async {
//   List<Map<String, dynamic>> allManga = await fetchAllComics();
//   DateTime now = DateTime.now();
//   DateTime oneMonthAgo = now.subtract(Duration(days: 30));

//   List<Map<String, dynamic>> filteredManga =
//       allManga
//           .where((manga) => manga["created_date"].isAfter(oneMonthAgo))
//           .toList()
//         ..sort((a, b) => b["view"].compareTo(a["view"]));

//   return filteredManga
//       .take(limit)
//       .map(
//         (manga) => manga.map((key, value) => MapEntry(key, value.toString())),
//       )
//       .toList();
// }

// // **Lấy truyện theo thể loại**
// Future<List<Map<String, String>>> getMangaByGenre({
//   required String genre,
//   required int limit,
// }) async {
//   List<Map<String, dynamic>> allManga = await getAllComics();

//   List<Map<String, dynamic>> filteredManga =
//       allManga
//           .where(
//             (manga) => manga["genres_id"].toLowerCase() == genre.toLowerCase(),
//           )
//           .toList()
//         ..sort((a, b) => b["view"].compareTo(a["view"]));

//   return filteredManga
//       .take(limit)
//       .map(
//         (manga) => manga.map((key, value) => MapEntry(key, value.toString())),
//       )
//       .toList();
// }

// Future<List<Map<String, dynamic>>> getFeatureComic({
//   required String rankingType,
//   required int limit,
// }) async {
//   await Future.delayed(Duration(seconds: 1)); // Giả lập thời gian tải dữ liệu

//   List<Map<String, dynamic>> data = [
//     {
//       "comic_id": "1",
//       "comic_name": "Touhou Chireikiden: Hansoku Tantei Satori",
//       "cover_url":
//           "https://mangadex.org/covers/f4fa3679-6918-4684-bcb6-377c9f336898/31d5e78e-a8f2-44fd-b1b0-94828a4f7fd4.jpg",
//       "user_id": "admin",
//       "created_date": DateTime(2025, 3, 10),
//       "quantity_chap": 15,
//       "description": "A manga from the Touhou Project universe.",
//       "status": 1,
//       "view": 6500,
//       "genres_id": "mystery",
//     },
//     {
//       "comic_id": "2",
//       "comic_name": "Lycoris Recoil",
//       "cover_url":
//           "https://mangadex.org/covers/9c21fbcd-e22e-4e6d-8258-7d580df9fc45/0184636a-f44c-4073-9b55-435120755e47.jpg",
//       "user_id": "admin",
//       "created_date": DateTime(2025, 3, 10),
//       "quantity_chap": 20,
//       "description": "An action-packed story about secret agents.",
//       "status": 1,
//       "view": 7200,
//       "genres_id": "action",
//     },
//     {
//       "comic_id": "3",
//       "comic_name": "Houkago Bokura wa Uchuu ni Madou",
//       "cover_url":
//           "https://mangadex.org/covers/91a2e0c9-cd81-4bf7-b5f7-bb37434bf6b3/7a41b522-5383-422b-b6b4-fc2007f5c603.jpg",
//       "user_id": "admin",
//       "created_date": DateTime(2025, 3, 10),
//       "quantity_chap": 10,
//       "description": "A sci-fi romance manga.",
//       "status": 1,
//       "view": 4800,
//       "genres_id": "sci-fi",
//     },
//     {
//       "comic_id": "4",
//       "comic_name": "Pocket Monsters: Liko's Treasure",
//       "cover_url":
//           "https://mangadex.org/covers/39c2752b-0d08-4bdc-8f99-4ac273fd194a/10f54e15-fda6-41c5-ae68-62d3de25dd71.jpg",
//       "user_id": "admin",
//       "created_date": DateTime(2025, 3, 10),
//       "quantity_chap": 8,
//       "description": "A Pokémon adventure story.",
//       "status": 1,
//       "view": 5300,
//       "genres_id": "adventure",
//     },
//   ];

//   return data.take(limit).toList();
// }

// Make formatDate function available for other files to import
String formatDate(dynamic dateInput) {
  if (dateInput == null) return "Không xác định"; // Kiểm tra null

  DateTime date;
  if (dateInput is String) {
    try {
      date = DateTime.parse(dateInput); // Chuyển từ chuỗi thành DateTime
    } catch (e) {
      return "Lỗi ngày tháng"; // Tránh lỗi nếu chuỗi sai định dạng
    }
  } else if (dateInput is DateTime) {
    date = dateInput; // Nếu đã là DateTime thì giữ nguyên
  } else {
    return "Lỗi ngày tháng"; // Tránh lỗi kiểu dữ liệu
  }

  // Trích xuất ngày, tháng, năm
  String formattedDate =
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

  return formattedDate;
}

// // **Lấy top truyện theo tuần (7 ngày)**
// Future<List<Map<String, dynamic>>> getTopComicOfWeek({
//   required int limit,
// }) async {
//   List<Map<String, dynamic>> allManga = await getAllComics();
//   DateTime now = DateTime.now();
//   DateTime oneWeekAgo = now.subtract(Duration(days: 7));

//   return allManga
//       .where((manga) => manga["created_date"].isAfter(oneWeekAgo))
//       .toList()
//     ..sort((a, b) => b["view"].compareTo(a["view"]))
//     ..take(limit).toList();
// }

// // **Lấy top truyện theo tháng (30 ngày)**
// Future<List<Map<String, dynamic>>> getTopComicOfMonth({
//   required int limit,
// }) async {
//   List<Map<String, dynamic>> allManga = await getAllComics();
//   DateTime now = DateTime.now();
//   DateTime oneMonthAgo = now.subtract(Duration(days: 30));

//   return allManga
//       .where((manga) => manga["created_date"].isAfter(oneMonthAgo))
//       .toList()
//     ..sort((a, b) => b["view"].compareTo(a["view"]))
//     ..take(limit).toList();
// }

// // **Lấy truyện nổi bật**
// Future<List<Map<String, dynamic>>> getFeatureComic({
//   required String rankingType,
//   required int limit,
// }) async {
//   await Future.delayed(Duration(seconds: 1)); // Giả lập thời gian tải dữ liệu

//   List<Map<String, dynamic>> allManga = await getAllComics();

//   // Nếu ranking type là tuần hoặc tháng, lọc theo thời gian tương ứng
//   if (rankingType == 'week') {
//     return getTopComicOfWeek(limit: limit);
//   } else if (rankingType == 'month') {
//     return getTopComicOfMonth(limit: limit);
//   } else {
//     // Mặc định (all) - Lấy theo lượt xem cao nhất
//     return allManga
//       ..sort((a, b) => b["view"].compareTo(a["view"]))
//       ..take(limit).toList();
//   }
// }
