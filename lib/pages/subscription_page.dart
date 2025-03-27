import 'package:flutter/material.dart';
import 'dart:io';
import 'package:rookiescomic_mobile/widgets/coin_packages.dart';
import 'package:rookiescomic_mobile/widgets/subscription_plans.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rookiescomic_mobile/pages/login_page.dart'; // Add this import

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? selectedPackage;
  String balance = "0 xu";
  String promotionBalance = "0 xu";
  String? userId;
  String? token;
  int? role;

  final List<Map<String, dynamic>> coinPackages = [
    {"id": 1, "coins": 100, "bonus": 10, "price": "20000", "popular": false},
    {"id": 2, "coins": 300, "bonus": 50, "price": "50000", "popular": true},
    {"id": 3, "coins": 500, "bonus": 100, "price": "80000", "popular": false},
  ];

  // Colors for the new design - updated to match login color scheme
  final Color primaryColor = const Color(0xFF4D4FC1);
  final Color secondaryColor = const Color(0xFFFF6B6B);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color textColor = const Color(0xFF2D3748);
  final Color accentColor = const Color(0xFF8082FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is important to trigger data refresh when returning from login page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? newUserId = prefs.getString("user_id");
    String? newToken = prefs.getString("backend_token");
    String? roleString = prefs.getString("role");
    int? newRole = roleString != null ? int.tryParse(roleString) : null;

    // Only update state if values have changed
    if (newUserId != userId || newToken != token || newRole != role) {
      setState(() {
        userId = newUserId;
        token = newToken;
        role = newRole;
      });

      // Debug: Kiểm tra dữ liệu lấy từ SharedPreferences
      print("DEBUG: userId = $userId");
      print("DEBUG: token = $token");
      print("DEBUG: role = $role");

      // Fetch balance if user is logged in
      if (userId != null && token != null) {
        _fetchBalance();
      }
    }
  }

  Future<void> _fetchBalance() async {
    if (userId == null || token == null) return;

    try {
      // Gọi API lấy số xu trong ví chính
      final mainWalletResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/wallets/$userId/main-wallet'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (mainWalletResponse.statusCode == 200) {
        final mainWalletData = jsonDecode(mainWalletResponse.body);
        setState(() {
          double balanceValue = (mainWalletData['balance'] as num).toDouble();
          balance =
              "${balanceValue.toInt()} xu"; // Chuyển số thập phân về số nguyên
        });
      }

      // Nếu user có role 7 hoặc 8, gọi API lấy ví khuyến mãi
      if (role == 7 || role == 8) {
        final promoWalletResponse = await http.get(
          Uri.parse('http://10.0.2.2:8080/wallets/$userId/promotion-wallet'),
          headers: {"Authorization": "Bearer $token"},
        );

        if (promoWalletResponse.statusCode == 200) {
          final promoWalletData = jsonDecode(promoWalletResponse.body);
          setState(() {
            double promoBalanceValue =
                (promoWalletData['balance'] as num).toDouble();
            promotionBalance =
                "${promoBalanceValue.toInt()} xu"; // Chuyển số thập phân về số nguyên
          });
        }
      }
    } catch (e) {
      print("Lỗi khi lấy số dư: $e");
    }
  }

  void buyCoinPackage(String price, String coin) async {
    if (userId == null || token == null) {
      showSnackbar("Vui lòng đăng nhập để tiếp tục!");
      return;
    }

    // Debug: In ra thông tin giao dịch
    print("DEBUG: Mua gói xu: $coin xu với giá $price VNĐ cho userId $userId");

    String returnUrl = "rookiescomic://momo-payment";
    String ipnUrl = "http://10.0.2.2:8080/momo/ipn-handler";

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/momo/create'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "price": price,
          "coin": coin,
          "userId": userId,
          "returnUrl": returnUrl,
          "ipnUrl": ipnUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? payUrl = data['payUrl'];

        if (payUrl != null) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Thanh toán MoMo"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/vi-momo.jpg",
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đóng"),
                    ),
                    TextButton(
                      onPressed:
                          () => launchUrl(
                            Uri.parse(payUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                      child: const Text("Mở MoMo"),
                    ),
                  ],
                ),
          );
        } else {
          showSnackbar("Không thể mở MoMo. Vui lòng thử lại!");
        }
      } else {
        showSnackbar("Lỗi khi tạo đơn hàng. Mã lỗi: ${response.statusCode}");
      }
    } catch (e) {
      showSnackbar("Đã có lỗi xảy ra. Vui lòng thử lại!");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nạp Xu & Đăng Ký Gói',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    buildBalanceSection(),
                    const SizedBox(height: 16),
                    buildTabBar(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, child) {
                          return _tabController.index == 1
                              ? SubscriptionPlans()
                              : CoinPackages(
                                coinPackages: coinPackages,
                                onSelected: (id) {
                                  setState(() {
                                    selectedPackage = id;
                                  });
                                },
                                onPayment: (price, coins) {
                                  buyCoinPackage(price, coins);
                                },
                                isLoggedIn: userId != null && token != null,
                              );
                        },
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),

            // PAYMENT Ở DƯỚI CÙNG
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return _tabController.index == 0
                    ? buildPaymentForCoins()
                    : buildPaymentForSubscription();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBalanceSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Số Dư Ví',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (userId == null || token == null)
                      OutlinedButton(
                        onPressed: () {
                          // Navigatae tới trang login
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          ).then((_) {
                            // Refresh lại khi người dùng login
                            setState(() {
                              // Clear data first
                              balance = "0 xu";
                              promotionBalance = "0 xu";
                            });
                            // Then reload user data
                            _loadUserData();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Đăng nhập'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  balance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (role == 7 || role == 8)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.card_giftcard,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              promotionBalance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Xu khuyến mãi',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: textColor,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, size: 16),
                SizedBox(width: 6),
                Text('Gói Xu'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book, size: 16),
                SizedBox(width: 6),
                Text('Gói Đọc Truyện'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentForCoins() {
    if (userId == null || token == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: const Text(
                'Vui lòng đăng nhập để mua gói xu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final selectedPkg = coinPackages.firstWhere(
      (p) => p["id"] == selectedPackage,
      orElse: () => {"price": null, "coins": null, "id": null},
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        // Padding để có gì đổi thiết bị không bị hư
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      child: ElevatedButton(
        onPressed:
            selectedPackage != null
                ? () => buyCoinPackage(
                  selectedPkg["price"].toString(),
                  selectedPkg["coins"].toString(),
                )
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedPackage != null ? primaryColor : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart),
            const SizedBox(width: 8),
            Text(
              selectedPackage != null
                  ? 'Thanh toán ${selectedPkg["price"]}đ'
                  : 'Chọn gói để thanh toán',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentForSubscription() {
    if (userId == null || token == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: const Text(
                'Vui lòng đăng nhập để mua gói đọc truyện',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        // BOTTOM PADDING ĐỂ TRASH BỊ CHE + HƯ MÀN khi đổi thiết bị
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monetization_on),
            SizedBox(width: 8),
            Text(
              'Thanh toán bằng Xu ảo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
