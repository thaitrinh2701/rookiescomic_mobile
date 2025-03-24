import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rookiescomic_mobile/pages/home_page.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn đã hủy đăng nhập.")),
      );
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) {
      throw Exception("Firebase login failed");
    }

    String? firebaseIdToken = await user.getIdToken();
    if (firebaseIdToken == null) {
      throw Exception("Failed to retrieve Firebase ID Token");
    }

    print("Firebase ID Token: $firebaseIdToken");

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/users/auth/google/android"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"credential": firebaseIdToken}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String backendToken = responseData["token"];

      // Giải mã token
      Map<String, dynamic> decodedToken = decodeJWT(backendToken);
      print("Decoded Token: $decodedToken");

      // Lưu token backend và thông tin người dùng vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("backend_token", backendToken);

      if (decodedToken.containsKey("userId")) {
        await prefs.setString("user_id", decodedToken["userId"]);
      } else {
        print("⚠️ Token không chứa userId!");
      }

      if (decodedToken.containsKey("sub")) {
        await prefs.setString("email", decodedToken["sub"]);
      } else {
        print("⚠️ Token không chứa email!");
      }

      if (decodedToken.containsKey("role") && decodedToken["role"] != null) {
        await prefs.setString("role", decodedToken["role"]);
      } else {
        print("⚠️ Lỗi: role bị null hoặc không tồn tại trong token!");
      }

      print("✅ Đăng nhập thành công!");
      print("🔹 Token đã lưu: ${prefs.getString("backend_token")}");
      print("🔹 User ID: ${prefs.getString("user_id")}");
      print("🔹 Email: ${prefs.getString("email")}");
      print("🔹 Role: ${prefs.getString("role")}");

      // Chuyển hướng về HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      throw Exception("Lỗi từ backend: ${response.body}");
    }
  } catch (e) {
    print("❌ Lỗi đăng nhập: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đăng nhập thất bại. Vui lòng thử lại!")),
    );
  }
}

// Hàm giải mã JWT
Map<String, dynamic> decodeJWT(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception("Invalid token format");
    }

    String payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    Map<String, dynamic> jsonPayload = jsonDecode(payload);

    return jsonPayload;
  } catch (e) {
    print("⚠️ Lỗi giải mã token: $e");
    return {}; // Trả về object rỗng nếu có lỗi
  }
}
