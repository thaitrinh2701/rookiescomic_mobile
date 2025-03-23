import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rookiescomic_mobile/pages/home_page.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    // Đăng nhập Google
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

    // Đăng nhập vào Firebase
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) {
      throw Exception("Firebase login failed");
    }

    // Lấy Firebase ID Token
    String? firebaseIdToken = await user.getIdToken();
    if (firebaseIdToken == null) {
      throw Exception("Failed to retrieve Firebase ID Token");
    }

    print("Firebase ID Token: $firebaseIdToken");

    // Gửi token lên backend
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/users/auth/google/android"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"credential": firebaseIdToken}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String backendToken = responseData["token"];

      // Lưu token backend vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("backend_token", backendToken);

      print("Đăng nhập BE thành công, token: $backendToken");

      // Chuyển hướng về HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      throw Exception("Lỗi từ backend: ${response.body}");
    }
  } catch (e) {
    print("Lỗi đăng nhập: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đăng nhập thất bại. Vui lòng thử lại!")),
    );
  }
}
