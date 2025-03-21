import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rookiescomic_mobile/pages/home_page.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    // Kiểm tra nếu đã có người dùng đăng nhập trước đó
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print("User đã đăng nhập: ${currentUser.displayName}");
      return;
    }

    // Đăng nhập Google
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Bạn đã hủy đăng nhập.")));
      return;
    }

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Tạo credentials
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Đăng nhập Firebase
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);
    User? user = userCredential.user;

    print("Đăng nhập thành công: ${user?.displayName}");

    // Thông báo đăng nhập thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đăng nhập thành công, xin chào ${user?.displayName}!"),
      ),
    );

    // Chuyển về HomePage sau khi đăng nhập thành công
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  } catch (e) {
    print("Lỗi đăng nhập: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đăng nhập thất bại. Vui lòng thử lại!")),
    );
  }
}
