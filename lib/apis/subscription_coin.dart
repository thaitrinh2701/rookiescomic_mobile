import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionCoinAPI {
  static Future<void> buyCoinPackage(BuildContext context, String price, String coin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    String? token = prefs.getString("backend_token");

    if (userId == null || token == null) {
      _showSnackbar(context, "Vui lòng đăng nhập để tiếp tục!");
      return;
    }

    print("DEBUG: Mua gói xu: $coin xu với giá $price VNĐ cho userId $userId");

    String returnUrl = "rookiescomic://momo-payment";
    String ipnUrl = "http://10.0.2.2:8080/momo/ipn-handler";

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/momo/create'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "price": price,
          "coin": coin,
          "userId": userId,
          "returnUrl": returnUrl,
          "ipnUrl": ipnUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? payUrl = data['payUrl'];

        if (payUrl != null) {
          _showPaymentDialog(context, payUrl);
        } else {
          _showSnackbar(context, "Không thể mở MoMo. Vui lòng thử lại!");
        }
      } else {
        _showSnackbar(context, "Lỗi khi tạo đơn hàng. Mã lỗi: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackbar(context, "Đã có lỗi xảy ra. Vui lòng thử lại!");
    }
  }

  static void _showPaymentDialog(BuildContext context, String payUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thanh toán MoMo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/vi-momo.jpg", height: 200, fit: BoxFit.cover),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
          TextButton(
            onPressed: () => launchUrl(Uri.parse(payUrl), mode: LaunchMode.externalApplication),
            child: const Text("Mở MoMo"),
          ),
        ],
      ),
    );
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
