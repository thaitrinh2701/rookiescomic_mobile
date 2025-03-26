import 'package:flutter/material.dart';
import 'dart:io';
import 'package:rookiescomic_mobile/widgets/coin_packages.dart';
import 'package:rookiescomic_mobile/widgets/subscription_plans.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String promotionBalance = "0 xu"; // Thêm biến để hiển thị số xu khuyến mãi
  String? userId;
  String? token;
  int? role; // Biến để lưu role của user

  final List<Map<String, dynamic>> coinPackages = [
    {"id": 1, "coins": 100, "bonus": 10, "price": "20000", "popular": false},
    {"id": 2, "coins": 300, "bonus": 50, "price": "50000", "popular": true},
    {"id": 3, "coins": 500, "bonus": 100, "price": "80000", "popular": false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString("user_id");
      token = prefs.getString("backend_token");

      // Sửa lỗi lấy role bị lỗi kiểu dữ liệu
      String? roleString = prefs.getString("role");
      role = roleString != null ? int.tryParse(roleString) : null;
    });

    // Debug: Kiểm tra dữ liệu lấy từ SharedPreferences
    print("DEBUG: userId = $userId");
    print("DEBUG: token = $token");
    print("DEBUG: role = $role");

    _fetchBalance();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: const Text(
          'Nạp Xu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                buildBalanceSection(), // Cập nhật để hiển thị số xu khuyến mãi
                const SizedBox(height: 20),
                buildTabBar(),
                const SizedBox(height: 20),
                AnimatedBuilder(
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
                        );
                  },
                ),
              ],
            ),
          ),
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
    );
  }

  Widget buildBalanceSection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.blue[700],
                size: 28,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số dư hiện tại',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    balance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (role == 7 || role == 8) // Chỉ hiển thị nếu role là 7 hoặc 8
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.green[700], size: 28),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xu khuyến mãi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        promotionBalance,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
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
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.blue,
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      tabs: const [Tab(text: 'Gói Xu'), Tab(text: 'Gói Đọc Truyện')],
    );
  }

  Widget buildPaymentForCoins() {
    final selectedPkg = coinPackages.firstWhere(
      (p) => p["id"] == selectedPackage,
      orElse: () => {"price": null, "coins": null},
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed:
            selectedPkg["price"] != null
                ? () => buyCoinPackage(
                  selectedPkg["price"].toString(),
                  selectedPkg["coins"].toString(),
                )
                : null,
        child: Text(
          selectedPkg["price"] != null
              ? 'Thanh toán ${selectedPkg["price"]}đ'
              : 'Chọn gói để thanh toán',
        ),
      ),
    );
  }

  Widget buildPaymentForSubscription() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Thanh toán bằng Xu ảo'),
      ),
    );
  }
}
