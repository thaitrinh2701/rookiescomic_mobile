import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/apis/google_signin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [_buildBackgroundImage(), _buildLoginForm(context)],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Image.network(
          'https://cdn.donmai.us/original/1f/99/__usami_renko_and_maribel_hearn_touhou_drawn_by_yuhezi__1f991ff8142e60a21cc5ec3c773214ed.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color.fromARGB((0.9 * 255).toInt(), 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            const SizedBox(height: 10),
            _buildTitle(),
            const SizedBox(height: 20),
            _buildTextField(emailController, "Email"),
            const SizedBox(height: 12),
            _buildTextField(passwordController, "Password", isPassword: true),
            const SizedBox(height: 12),
            _buildLoginButton(),
            const SizedBox(height: 12),
            _buildDivider(),
            const SizedBox(height: 12),
            _buildGoogleLoginButton(), // Gọi hàm Google login khi nhấn nút
            const SizedBox(height: 12),
            _buildForgotPassword(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 250,
      height: 100,
      child: Image.asset("assets/images/logo_2.png", fit: BoxFit.contain),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        "WELCOME BACK, ROOKIE !!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w100,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4D4FC1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4D4FC1), width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4D4FC1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          _login();
        },
        child: const Text(
          "Sign in",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Colors.black)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("OR", style: TextStyle(color: Colors.black)),
        ),
        Expanded(child: Divider(color: Colors.black)),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.black),
          ),
        ),
        onPressed: () async {
          await signInWithGoogle(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/google_icon.png", height: 24),
            const SizedBox(width: 12),
            const Text("Sign in with Google", style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  void _login() {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const HomePage()),
    // );
  }
}
