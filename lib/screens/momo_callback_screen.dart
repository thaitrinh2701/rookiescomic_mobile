import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoMoCallbackScreen extends StatefulWidget {
  final Uri uri;
  const MoMoCallbackScreen({Key? key, required this.uri}) : super(key: key);

  @override
  _MoMoCallbackScreenState createState() => _MoMoCallbackScreenState();
}

class _MoMoCallbackScreenState extends State<MoMoCallbackScreen> {
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _handleMomoPayment();
  }

  Future<void> _handleMomoPayment() async {
    final orderId = widget.uri.queryParameters["orderId"] ?? "";
    final requestId = widget.uri.queryParameters["requestId"] ?? "";
    final resultCode = int.tryParse(widget.uri.queryParameters["resultCode"] ?? "99") ?? 99;
    final extraData = widget.uri.queryParameters["extraData"] ?? ""; // Lấy extraData từ URL

    if (orderId.isEmpty || requestId.isEmpty) {
      print("Thiếu orderId hoặc requestId, không thể gửi lên server.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/momo/ipn-handler'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "orderId": orderId,
          "requestId": requestId,
          "resultCode": resultCode,
          "extraData": extraData, // Gửi extraData lên server
        }),
      );

      if (response.statusCode == 200) {
        print("Gửi IPN thành công: $response");
      } else {
        print("Gửi IPN thất bại: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Lỗi khi gửi IPN: $e");
    }

    setState(() => _isProcessing = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isProcessing
            ? CircularProgressIndicator()
            : Text("Xử lý hoàn tất, đang chuyển về trang chủ..."),
      ),
    );
  }
}
