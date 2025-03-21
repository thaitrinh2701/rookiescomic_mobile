import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final User? user;
  final String? idToken; // Nhận idToken từ constructor

  const HomePage({Key? key, required this.user, required this.idToken})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Center(
        child:
            user != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoURL ?? ""),
                      radius: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Hello, ${user!.displayName}!",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "Email: ${user!.email}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    // In ra ID Token
                    // Text(
                    //   "ID Token: $idToken", // In ID Token
                    //   style: TextStyle(fontSize: 16),
                    // ),
                    SizedBox(height: 20),
                    // Nút logout
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut(); // Đăng xuất
                        // Quay lại LoginPage
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text("Logout"),
                    ),
                  ],
                )
                : Text("User not found"),
      ),
    );
  }
}
