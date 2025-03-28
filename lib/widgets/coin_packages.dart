import 'package:flutter/material.dart';

class CoinPackages extends StatefulWidget {
  final Function(int) onSelected;
  final Function(String, String) onPayment;
  final List<Map<String, dynamic>> coinPackages;
  final bool isLoggedIn;

  const CoinPackages({
    super.key,
    required this.onSelected,
    required this.onPayment,
    required this.coinPackages,
    this.isLoggedIn = true,
  });

  @override
    State<CoinPackages> createState() => _CoinPackagesState();
  }

  class _CoinPackagesState extends State<CoinPackages> {
    int? selectedPackage;
    // Updated colors to match subscription page
    final Color primaryColor = const Color(
      0xFF4D4FC1,
    ); // Changed to match login page color
    final Color secondaryColor = const Color(
      0xFFFF6B6B,
    ); // Keeping the soft coral/red
    final Color accentColor = const Color(0xFF8082FF); // Lighter shade of primary
    final Color orangeColor = const Color(
      0xFFFF9800,
    ); // Orange for "Phổ biến" badge
    final Color blueColor = const Color(0xFF42A5F5); // Blue for bonus xu badge

    @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Chọn gói xu phù hợp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...widget.coinPackages.map(
          (pkg) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: selectedPackage == pkg["id"]
                  ? LinearGradient(
                      colors: [primaryColor, accentColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selectedPackage == pkg["id"] ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    selectedPackage = pkg["id"];
                  });
                  widget.onSelected(pkg["id"]);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: selectedPackage == pkg["id"]
                                  ? Colors.white.withOpacity(0.3)
                                  : accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.monetization_on,
                              color: selectedPackage == pkg["id"]
                                  ? Colors.white
                                  : accentColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pkg["coins"]} xu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedPackage == pkg["id"]
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              if (pkg["bonus"] > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedPackage == pkg["id"]
                                        ? Colors.white.withOpacity(0.3)
                                        : blueColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '+${pkg["bonus"]} xu bonus',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${pkg["price"]}đ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selectedPackage == pkg["id"]
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          if (selectedPackage == pkg["id"])
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Đã chọn',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Xu sẽ được thêm vào tài khoản của bạn ngay sau khi thanh toán thành công. Xu không có thời hạn sử dụng.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),

        // Nút thanh toán
        const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: double.infinity, // Chiều rộng tối đa
              margin: const EdgeInsets.symmetric(horizontal: 16), // Khoảng cách hai bên
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4D4FC1), Color(0xFF8082FF)], // Gradient xanh tím
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: selectedPackage != null
                    ? () {
                        final selectedPkg = widget.coinPackages.firstWhere(
                            (pkg) => pkg["id"] == selectedPackage);

                        widget.onPayment(
                          selectedPkg["price"].toString(),
                          selectedPkg["coins"].toString(),
                        ); // Gọi hàm thanh toán
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Nền trong suốt để hiển thị gradient
                  shadowColor: Colors.transparent, // Bỏ bóng của ElevatedButton
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedPackage != null
                      ? 'Thanh toán ${widget.coinPackages.firstWhere((pkg) => pkg["id"] == selectedPackage)["price"]}đ'
                      : 'Chọn gói xu',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24), // Đẩy button xuống dưới
      ],
    );
  }
}