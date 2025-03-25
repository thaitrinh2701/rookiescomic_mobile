import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/pages/home_page.dart';
import 'package:rookiescomic_mobile/screens/momo_callback_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleDeepLink();
  }

  final AppLinks _appLinks = AppLinks();

    void _handleDeepLink() {
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null && uri.host.contains("momo-payment")) {
        _navigateToCallback(uri);
      }
    });

    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host.contains("momo-payment")) {
        _navigateToCallback(uri);
      }
    }, onError: (err) {
      print("Lỗi App Links: $err");
    });
  }

  void _navigateToCallback(Uri uri) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => MoMoCallbackScreen(uri: uri)),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoGlowScrollBehavior(),
      navigatorKey: navigatorKey,
      home: HomePage(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Coiny",
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Tắt glow effect toàn bộ app
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
