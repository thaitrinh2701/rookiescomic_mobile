import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rookiescomic_mobile/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCartApi {
  static const String apiUrl = "http://10.0.2.2:8080/orders";

  static Future<bool> addToCart(CartItem item) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("user_id");
      if (userId == null) return false;

      var requestBody = {
        "userId": userId,
        "status": 0,
        "orderDetails": [
          {
            "chapterId": item.chapterId,
            "price": 999,
            "status": 1,
          }
        ]
      };

      print("JSON gửi lên: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("🔥 Error adding to cart: $e");
      return false;
    }
  }

  // Hàm lấy order UNORDERED của user
  static Future<Map<String, dynamic>?> fetchOrderByUserAndStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("user_id");
      if (userId == null) return null;

      final response = await http.post(
        Uri.parse("$apiUrl/find-by-user-and-status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "orderId": userId,
          "newStatusByte": 0, // UNORDERED
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về dữ liệu order
      } else {
        return null; // Không tìm thấy đơn hàng
      }
    } catch (e) {
      print("Error fetching order: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateOrderStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("user_id");
      if (userId == null) return null;

      var requestBody = {
        "userId": userId,
        "newStatusByte": 2 // 2 là trạng thái COMPLETED
      };

      print("JSON gửi lên: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$apiUrl/update-status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái đơn hàng: $e");
      return null;
    }
  }
}
