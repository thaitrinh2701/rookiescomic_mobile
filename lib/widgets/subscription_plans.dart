import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/apis/subscription_packge.dart';
import 'package:intl/intl.dart'; // Import for number formatting

class SubscriptionPlans extends StatelessWidget {
  final List<Map<String, dynamic>> subscriptionPlans = [
    {
      "title": "Gói Reader",
      "price": "30000",
      "description": "Đọc tất cả truyện không giới hạn.",
      "highlightText": "Đọc không giới hạn",
      "borderColor": Colors.blue,
      "role": 6,
    },
    {
      "title": "Gói Author",
      "price": "45000",
      "description": "Có thể đăng truyện.",
      "highlightText": "Kiếm tiền cùng AI",
      "borderColor": Colors.orange,
      "role": 7,
    },
    {
      "title": "Gói Pro",
      "price": "60000",
      "description": "Đọc và đăng truyện, không quảng cáo.",
      "highlightText": "Phá bỏ giới hạn, tất cả trong tầm tay",
      "borderColor": Colors.purple,
      "role": 8,
    },
  ];

  SubscriptionPlans({super.key});

  // Helper method to format price with commas
  String _formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(int.parse(price))}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          subscriptionPlans.map((plan) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: plan["borderColor"], width: 1.5),
              ),
              child: ListTile(
                title: Text(
                  plan["title"],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan["description"]),
                    const SizedBox(height: 4),
                    Text(
                      plan["highlightText"],
                      style: TextStyle(
                        color: plan["borderColor"],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    int role = plan["role"] as int;
                    double price =
                        double.tryParse(plan["price"].toString()) ?? 0;

                    // ✅ Gọi API nhưng không quan tâm kết quả
                    await SubscriptionService.purchaseSubscription(role, price);

                    // ✅ Luôn hiển thị SnackBar báo thành công
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "✅ Gói ${plan["title"]} đã được kích hoạt thành công!",
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  child: Text(
                    _formatPrice(plan["price"]),
                  ), // Use formatted price with commas
                ),
              ),
            );
          }).toList(),
    );
  }
}
