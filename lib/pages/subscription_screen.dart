import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chọn gói đăng ký",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSubscriptionPlan(
              title: "Gói Reader",
              price: "30k VND/tháng",
              description: "Đọc tất cả truyện không giới hạn.",
              highlightText: "Đọc không giới hạn",
              bgColor: Colors.grey[900]!,
              borderColor: Colors.blueAccent,
            ),
            _buildSubscriptionPlan(
              title: "Gói Author",
              price: "45k VND/tháng",
              description: "Có thể đăng truyện.",
              highlightText: "Kiếm tiền cùng AI",
              bgColor: Colors.grey[900]!,
              borderColor: Colors.orange,
            ),
            _buildSubscriptionPlan(
              title: "Gói Pro",
              price: "60k VND/tháng",
              description: "Đọc và đăng truyện, không quảng cáo.",
              highlightText: "Phá bỏ giới hạn, tất cả trong tầm tay",
              bgColor: Colors.grey[900]!,
              borderColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlan({
    required String title,
    required String price,
    required String description,
    required String highlightText,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Highlight Text (Ví dụ: "Dùng thử 7 ngày miễn phí")
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              highlightText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),

          // 🌟 Tiêu đề gói + Giá
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),

          // 📌 Mô tả gói
          Text(
            description,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 15),

          // 🎯 Nút đăng ký
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Xử lý đăng ký
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Đăng ký ngay"),
            ),
          ),

          // 📌 Lưu ý nhỏ (nếu cần)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Bạn có thể huỷ bất cứ lúc nào.",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
