import 'package:flutter/material.dart';
import 'package:rookiescomic_mobile/models/cart_item.dart';
import 'package:rookiescomic_mobile/models/chapter.dart';
import 'package:rookiescomic_mobile/models/comics.dart';

class CartScreen extends StatefulWidget {
  final Map<String, dynamic>? args;

  const CartScreen({Key? key, this.args}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Changed to static to persist between instances
  static List<CartItem> _cartItems = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    // Check if we have arguments passed to add to cart
    if (widget.args != null &&
        widget.args!.containsKey('comic') &&
        widget.args!.containsKey('chapter')) {
      final Comic comic = widget.args!['comic'];
      final Chapter chapter = widget.args!['chapter'];

      // Add the item to cart if it's not already there
      _addToCart(
        CartItem(
          comicId: comic.comicId,
          comicName: comic.comicName,
          coverUrl: comic.coverUrl,
          chapterId: chapter.chapterId,
          chapterName: chapter.chapterName ?? 'Unnamed Chapter',
          price: chapter.price,
        ),
      );
    }
    _calculateTotal();
  }

  void _addToCart(CartItem item) {
    // Check if the item is already in the cart
    final exists = _cartItems.any(
      (cartItem) =>
          cartItem.comicId == item.comicId &&
          cartItem.chapterId == item.chapterId,
    );

    if (!exists) {
      setState(() {
        _cartItems.add(item);
      });
      _calculateTotal();
    }
  }

  void _removeFromCart(CartItem item) {
    setState(() {
      _cartItems.removeWhere(
        (cartItem) =>
            cartItem.comicId == item.comicId &&
            cartItem.chapterId == item.chapterId,
      );
    });
    _calculateTotal();
  }

  void _calculateTotal() {
    setState(() {
      _totalAmount = _cartItems.fold(0, (sum, item) => sum + item.price);
    });
  }

  void _checkout() {
    // Simulate purchase and return to previous screen with updated unlock status
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thanh toán thành công'),
            content: Text('Bạn đã mở khóa ${_cartItems.length} chương truyện.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog

                  // Only pop back to reading screen if we came from there
                  if (widget.args != null) {
                    Navigator.pop(
                      context,
                      true,
                    ); // Return to reading screen with success flag
                  }

                  // Clear cart after successful purchase
                  setState(() {
                    _cartItems.clear();
                    _calculateTotal();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: const Color(0xFF4D4FC1),
        foregroundColor: Colors.white,
      ),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartList(),
      bottomNavigationBar: _cartItems.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng của bạn đang trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D4FC1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comic Cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.coverUrl,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 70,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        ),
                  ),
                ),
                const SizedBox(width: 16),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.comicName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.chapterName,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${item.price} xu',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4D4FC1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Remove Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeFromCart(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng thanh toán:',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '${_totalAmount.toStringAsFixed(0)} xu',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4D4FC1),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D4FC1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Thanh toán', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
