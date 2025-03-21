import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rookiescomic_mobile/apis/google_signout.dart';
import 'package:rookiescomic_mobile/pages/login_page.dart';
import 'package:rookiescomic_mobile/pages/subscription_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool notificationsEnabled = false;
  bool lightMode = false;
  bool darkMode = false;

  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt"),
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      extendBodyBehindAppBar: true,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle("Tài khoản"),
          _buildProfileTile(),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: "Thông báo",
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),
          SizedBox(height: 20),
          _buildSectionTitle("Giao diện"),
          _buildSwitchTile(
            icon: Icons.nights_stay,
            title: "Dark Mode",
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
                lightMode = !value;
              });
            },
          ),
          SizedBox(height: 20),
          _buildSectionTitle("Monetization"),
          _buildListTile(
            icon: Icons.monetization_on,
            title: "Đăng ký gói",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionScreen()),
              );
            },
          ),
          SizedBox(height: 20),
          _buildSectionTitle("Hỗ trợ"),
          _buildListTile(icon: Icons.help_outline, title: "Trung tâm trợ giúp"),
          if (_user != null)
            _buildListTile(
              icon: Icons.logout,
              title: "Đăng xuất",
              titleColor: Colors.red,
              onTap: () async {
                bool confirm = await _showLogoutDialog(context);
                if (confirm) {
                  logoutGoogle(context);
                }
              },
            ),
          SizedBox(height: 30),
          Center(
            child: Text(
              "Rookies Comic v1.0.0\n© 2025 Rookies Comic. All rights reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            _user?.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
        child: _user?.photoURL == null ? Icon(Icons.person) : null,
      ),
      title: Text(
        _user?.displayName ?? "Khách hàng",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _user?.displayName != null ? Color(0xFF4D4FC1) : Colors.black,
        ),
      ),

      subtitle:
          _user?.email != null
              ? Text(_user!.email!)
              : InkWell(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  ).then(
                    (_) => _fetchUserInfo(),
                  ); // Cập nhật thông tin sau khi quay lại
                },
                borderRadius: BorderRadius.circular(8), // Bo góc hiệu ứng chạm
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ), // Tăng vùng chạm
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login, color: Color(0xFF4D4FC1), size: 20),
                      SizedBox(width: 5),
                      Text(
                        "Đăng nhập",
                        style: TextStyle(
                          color: Color(0xFF4D4FC1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Đăng xuất"),
                content: Text("Bạn có chắc chắn muốn đăng xuất không?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Đồng ý"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Từ chối", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color titleColor = Colors.black,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: TextStyle(color: titleColor)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
