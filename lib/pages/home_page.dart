import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rookiescomic_mobile/pages/login_page.dart';
import 'package:rookiescomic_mobile/screens/category_screen.dart';
import 'package:rookiescomic_mobile/screens/comic_screen.dart';
import 'package:rookiescomic_mobile/screens/setting_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.index});

  final int? index;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    if (widget.index != null) {
      _selectedIndex = widget.index!;
    }
  }

  Future<void> _checkUserStatus() async {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Comic'),
    const NavigationDestination(icon: Icon(Icons.category), label: 'Danh mục'),
    const NavigationDestination(
      icon: Icon(Icons.library_books),
      label: 'Thư viện',
    ),
    const NavigationDestination(icon: Icon(Icons.settings), label: 'Cài đặt'),
  ];

  final List<Widget> _screens = [
    // const Center(child: Text('Comic')),
    const ComicScreen(),
    const CategoryScreen(),
    const Center(child: Text('Thư viện')),
    const SettingScreen(),
  ];

  void _handleNavigation(int index) async {
    if (index == 2 && _user == null) {
      _showLoginSnackBar();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLoginSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Bạn cần đăng nhập để truy cập thư viện."),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "Đăng nhập",
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
            _checkUserStatus();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Tránh màu xanh
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: _handleNavigation,
        backgroundColor: Colors.white,
      ),
    );
  }
}
