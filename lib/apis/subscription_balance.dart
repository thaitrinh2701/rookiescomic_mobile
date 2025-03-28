import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionBalanceAPI {
  static Future<Map<String, String>> fetchBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    String? token = prefs.getString("backend_token");
    String? roleString = prefs.getString("role");
    int? role = roleString != null ? int.tryParse(roleString) : null;

    if (userId == null || token == null) return {"balance": "0 xu", "promotionBalance": "0 xu"};

    Map<String, String> balances = {"balance": "0 xu", "promotionBalance": "0 xu"};

    try {
      // Gọi API lấy số dư ví chính
      final mainWalletResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/wallets/$userId/main-wallet'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (mainWalletResponse.statusCode == 200) {
        final mainWalletData = jsonDecode(mainWalletResponse.body);
        balances["balance"] = "${(mainWalletData['balance'] as num).toInt()} xu";
      }

      // Nếu user có role 7 hoặc 8, gọi API lấy số dư ví khuyến mãi
      if (role == 7 || role == 8) {
        final promoWalletResponse = await http.get(
          Uri.parse('http://10.0.2.2:8080/wallets/$userId/promotion-wallet'),
          headers: {"Authorization": "Bearer $token"},
        );

        if (promoWalletResponse.statusCode == 200) {
          final promoWalletData = jsonDecode(promoWalletResponse.body);
          balances["promotionBalance"] = "${(promoWalletData['balance'] as num).toInt()} xu";
        }
      }
    } catch (e) {
      print("Lỗi khi lấy số dư: $e");
    }

    return balances;
  }
}
