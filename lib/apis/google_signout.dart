import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logoutGoogle(BuildContext context) async {
  try {
    // Đăng xuất khỏi FirebaseAuth
    await FirebaseAuth.instance.signOut();

    // Đăng xuất khỏi GoogleSignIn
    GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    // Xóa SharedPreferences (nếu có lưu thông tin đăng nhập)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa tất cả dữ liệu đã lưu

    // Chuyển hướng về HomePage và xóa tất cả màn hình trước đó
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );

    // Hiển thị thông báo đăng xuất thành công
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đăng xuất thành công!")));
  } catch (e) {
    print("Error signing out: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lỗi khi đăng xuất, vui lòng thử lại!")),
    );
  }
}
