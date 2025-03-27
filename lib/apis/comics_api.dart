import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comics.dart';

const String baseUrl =
    'http://10.0.2.2:8080'; // ✅ Dùng IP mặc định của emulator

Future<List<Comic>> fetchAllComics() async {
  const String apiUrl = 'http://10.0.2.2:8080/api/comics';

  final response = await http.get(Uri.parse(apiUrl));
  print("==> Response status: ${response.statusCode}");
  print("==> Response body: ${response.body}");

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Comic.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load comics');
  }
}

Future<List<Comic>> fetchTopWeekComics({required int limit}) async {
  const String apiUrl = '$baseUrl/comics/top-week';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Comic.fromJson(json)).toList();
  } else {
    print(
      '❌ Failed to fetch top week comics: ${response.statusCode} - ${response.body}',
    );
    throw Exception('Failed to load top week comics');
  }
}

Future<List<Comic>> fetchTopMonthComics({required int limit}) async {
  const String apiUrl = '$baseUrl/comics/top-month';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => Comic.fromJson(json)).toList();
  } else {
    print(
      '❌ Failed to fetch top month comics: ${response.statusCode} - ${response.body}',
    );
    throw Exception('Failed to load top month comics');
  }
}
