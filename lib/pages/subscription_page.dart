import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/apis/subscription_balance.dart';
import 'package:rookiescomic_mobile/apis/subscription_coin.dart';
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
  String balance = "0 xu";
  String promotionBalance = "0 xu";

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
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    Map<String, String> balances = await SubscriptionBalanceAPI.fetchBalance();
    setState(() {
      balance = balances["balance"]!;
      promotionBalance = balances["promotionBalance"]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Nạp Xu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gói Xu'),
            Tab(text: 'Gói Người Dùng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoinPurchaseTab(),
          SubscriptionPlans(),
        ],
      ),
    );
  }

  Widget _buildCoinPurchaseTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Số dư: $balance", style: const TextStyle(fontSize: 16)),
              Text("Xu khuyến mãi: $promotionBalance", style: const TextStyle(fontSize: 16, color: Colors.green)),
            ],
          ),
        ),
        Expanded(
          child: CoinPackages(
            coinPackages: coinPackages,
            onSelected: (id) {
              setState(() {
                selectedPackage = id;
              });
            },
            onPayment: (price, coins) {
              SubscriptionCoinAPI.buyCoinPackage(context, price, coins);
            },
          ),
        ),
      ],
    );
  }
}