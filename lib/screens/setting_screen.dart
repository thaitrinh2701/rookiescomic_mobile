import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rookiescomic_mobile/apis/google_signout.dart';
import 'package:rookiescomic_mobile/pages/login_page.dart';
import 'package:rookiescomic_mobile/pages/subscription_page.dart';
import 'package:rookiescomic_mobile/screens/cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<int?> getRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? roleString = prefs.getString("role");
      print("Retrieved roleString: $roleString");
      return roleString != null ? int.tryParse(roleString) : null;
    } catch (e) {
      print("Error getting role: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt"),
        automaticallyImplyLeading: false, // Ẩn nút back
        toolbarHeight: 60,
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
          _buildSectionTitle("Truyện trả phí"),
          _buildListTile(
            icon: Icons.shopping_cart,
            title: "Giỏ hàng",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
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
    return FutureBuilder<int?>(
      future: getRole(),
      builder: (context, snapshot) {
        String roleText = "Khách vãng lai"; // Mặc định nếu không có dữ liệu

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          switch (snapshot.data) {
            case 1:
              roleText = "Quản trị viên";
              break;
            case 2:
              roleText = "Quản lý";
              break;
            case 3:
              roleText = "Người kiểm duyệt";
              break;
            case 4:
              roleText = "Nhân viên";
              break;
            case 5:
              roleText = "Khách hàng thường";
              break;
            case 6:
              roleText = "Người đọc";
              break;
            case 7:
              roleText = "Tác giả";
              break;
            case 8:
              roleText = "Khách hàng VIP";
              break;
          }
        }

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
              color:
                  _user?.displayName != null ? Color(0xFF4D4FC1) : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_user?.email != null) Text(_user!.email!),
              if (roleText != null)
                Text(
                  "Vai trò: $roleText",
                  style: TextStyle(color: Colors.grey),
                ),
              if (_user?.email == null)
                InkWell(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    ).then((_) => _fetchUserInfo());
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
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
            ],
          ),
        );
      },
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
                    child: Text("Từ chối"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Đồng ý", style: TextStyle(color: Colors.red)),
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
