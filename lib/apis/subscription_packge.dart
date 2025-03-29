import 'dart:convert';
import 'package:flutter/material.dart'; // ✅ Import Flutter UI
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static Future<String?> updateUserRole(String userId, int newRole) async {
    final url = Uri.parse("$baseUrl/users/update-role");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "newRoleByte": newRole}),
    );

    print("🔍 API Response: ${response.body}"); // 👉 Kiểm tra dữ liệu nhận được

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ walletId nhận được: ${data["walletId"]}");
      return data["walletId"]; // Trả về walletId
    }

    print("❌ Lỗi khi cập nhật vai trò");
    return null;
  }

  static Future<bool> createTransaction(double amount, String walletId) async {
    final url = Uri.parse("$baseUrl/transaction");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount,
        "walletId": walletId,
        "type": 1,
        "status": 4,
        "transactionTime": DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
      return false;
    }
  }

  static Future<String?> purchaseSubscription(int newRole, double cost) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");

    if (userId == null) {
      return "⚠️ Không tìm thấy thông tin tài khoản. Vui lòng đăng nhập lại.";
    }

    // ✅ Gọi API để lấy `walletId`
    String? walletId = await updateUserRole(userId, newRole);
    if (walletId == null) {
      return "⚠️ Cập nhật vai trò thất bại. Không thể lấy walletId.";
    }

    bool transactionSuccess = await createTransaction(cost, walletId);
    if (!transactionSuccess) {
      return "❌ Thanh toán không thành công. Vui lòng thử lại!";
    }

    return "✅ Gói $newRole đã được kích hoạt thành công!";
  }
}
