import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/pages/home_page.dart';

Future<void> logoutGoogle(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    // Chuyển hướng về HomePage và xóa tất cả các màn hình trước đó
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    print("Error signing out: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lỗi khi đăng xuất, vui lòng thử lại!")),
    );
  }
}
