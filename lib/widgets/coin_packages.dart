import 'package:flutter/material.dart';

class CoinPackages extends StatefulWidget {
  final Function(int) onSelected;
  final Function(String, String) onPayment; // Thêm hàm xử lý thanh toán
  final List<Map<String, dynamic>> coinPackages;

  const CoinPackages({
    Key? key,
    required this.onSelected,
    required this.onPayment,
    required this.coinPackages,
  }) : super(key: key);

  @override
  State<CoinPackages> createState() => _CoinPackagesState();
}

class _CoinPackagesState extends State<CoinPackages> {
  int? selectedPackage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.coinPackages.map(
          (pkg) => GestureDetector(
            onTap: () {
              setState(() {
                selectedPackage = pkg["id"];
              });
              widget.onSelected(pkg["id"]);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedPackage == pkg["id"]
                      ? Color(0xFF4D4FC1)
                      : Colors.grey.shade300,
                  width: selectedPackage == pkg["id"] ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: Color(0xFF4D4FC1).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.monetization_on,
                                color: Color(0xFF4D4FC1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${pkg["coins"]} xu',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (pkg["bonus"] > 0)
                                  Text(
                                    '+${pkg["bonus"]} xu bonus',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${pkg["price"]}đ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (selectedPackage == pkg["id"])
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                height: 20,
                                width: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4D4FC1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (pkg["popular"])
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4D4FC1),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Phổ biến',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Xu sẽ được thêm vào tài khoản của bạn ngay sau khi thanh toán thành công. Xu không có thời hạn sử dụng.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        /// Nút Thanh toán ở cuối màn hình
        ElevatedButton(
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
            backgroundColor: selectedPackage != null ? Colors.blue : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: Text(selectedPackage != null
              ? 'Thanh toán ${widget.coinPackages.firstWhere((pkg) => pkg["id"] == selectedPackage)["price"]}đ'
              : 'Chọn gói xu'),
        ),
      ],
    );
  }
}
