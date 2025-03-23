import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/widgets/coin_packages.dart';
import 'package:rookiescomic_mobile/widgets/subscription_plans.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? selectedPackage;

  final List<Map<String, dynamic>> coinPackages = [
    {"id": 1, "coins": 100, "bonus": 10, "price": "20,000", "popular": false},
    {"id": 2, "coins": 300, "bonus": 50, "price": "50,000", "popular": true},
    {"id": 3, "coins": 500, "bonus": 100, "price": "80,000", "popular": false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                buildBalanceSection(),
                const SizedBox(height: 20),
                buildTabBar(),
                const SizedBox(height: 20),

                // Sử dụng AnimatedBuilder để cập nhật UI khi đổi tab
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
                        );
                  },
                ),
              ],
            ),
          ),

          // Footer hiển thị phương thức thanh toán theo từng tab
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

  /// **Hiển thị số dư xu của user**
  Widget buildBalanceSection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    '0 xu', // TODO: Lấy số dư từ API
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () {
              // TODO: Mở lịch sử giao dịch
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(40, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              'Lịch sử giao dịch',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// **Tab điều hướng giữa Gói Xu và Gói Đọc Truyện**
  Widget buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(0xFF4D4FC1),
        ),
        indicatorSize: TabBarIndicatorSize.tab, // Fix kích thước indicator
        splashFactory: NoSplash.splashFactory, // Tắt hiệu ứng nhấp chuột
        labelColor: Colors.white, // Chữ đậm hơn khi chọn
        unselectedLabelColor: Colors.grey[600], // Chữ mờ hơn khi không chọn
        tabs: const [Tab(text: 'Gói Xu'), Tab(text: 'Gói Đọc Truyện')],
      ),
    );
  }

  /// **Thanh toán MoMo cho Gói Xu**
  Widget buildPaymentForCoins() {
    final selectedPkg = coinPackages.firstWhere(
      (p) => p["id"] == selectedPackage,
      orElse: () => {"price": null},
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/vi/f/fe/MoMo_Logo.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                const Text('Ví MoMo', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: selectedPkg["price"] != null ? () {} : null,
              child: Text(
                selectedPkg["price"] != null
                    ? 'Thanh toán ${selectedPkg["price"]}đ'
                    : 'Chọn gói để thanh toán',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **Thanh toán bằng Xu cho Gói Đọc Truyện**
  Widget buildPaymentForSubscription() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20), // Tạo khoảng cách
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Xử lý thanh toán bằng Xu ảo
              },
              child: const Text('Thanh toán bằng Xu ảo'),
            ),
          ),
        ],
      ),
    );
  }
}
