import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoGlowScrollBehavior(), // Tắt hiệu ứng overscroll
      home: HomePage(),
      theme: ThemeData(
        useMaterial3: true, // Tắt Material 3
        fontFamily: "Coiny",
      ),
    );
  }
}

// Tắt glow effect toàn bộ app
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
