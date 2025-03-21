import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart'; // Import HomePage

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await signInWithGoogle(context); // Truyền context vào hàm
          },
          child: const Text('Login with Google'),
        ),
      ),
    );
  }

  signInWithGoogle(BuildContext context) async {
    // Tiến hành đăng nhập bằng Google
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Tạo credentials từ accessToken và idToken của Google
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Đăng nhập với Firebase bằng credential
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);

    // Lấy ID Token
    String? idToken = await userCredential.user?.getIdToken();

    print(idToken);

    // Điều hướng sang trang HomePage và truyền user cùng idToken
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => HomePage(
              user: userCredential.user, // Truyền user vào HomePage
              idToken: idToken, // Truyền ID Token vào HomePage
            ),
      ),
    );
  }
}
