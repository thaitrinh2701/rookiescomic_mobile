import 'package:flutter/material.dart';

class SubscriptionPlans extends StatelessWidget {
  final List<Map<String, dynamic>> subscriptionPlans = [
    {
      "title": "Gói Reader",
      "price": "30.000 xu/tháng",
      "description": "Đọc tất cả truyện không giới hạn.",
      "highlightText": "Đọc không giới hạn",
      "borderColor": Colors.blue,
    },
    {
      "title": "Gói Author",
      "price": "45.000 xu/tháng",
      "description": "Có thể đăng truyện.",
      "highlightText": "Kiếm tiền cùng AI",
      "borderColor": Colors.orange,
    },
    {
      "title": "Gói Pro",
      "price": "60.000 xu/tháng",
      "description": "Đọc và đăng truyện, không quảng cáo.",
      "highlightText": "Phá bỏ giới hạn, tất cả trong tầm tay",
      "borderColor": Colors.purple,
    },
  ];

  SubscriptionPlans({super.key});

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
                trailing: Text(
                  plan["price"],
                  style: TextStyle(
                    color: plan["borderColor"],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
