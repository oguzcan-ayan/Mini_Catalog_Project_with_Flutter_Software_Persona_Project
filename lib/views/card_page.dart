import 'package:flutter/material.dart';
import 'package:mini_catalog_project/models/product_model.dart';

class CardPage extends StatefulWidget {
  final List<ProductsModel> productModels;
  final Set<int> cardIds;

  const CardPage({
    super.key,
    required this.productModels,
    required this.cardIds,
  });

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  // Map to store quantity for each product (using product id as key)
  Map<int, int> quantities = {};

  @override
  void initState() {
    super.initState();
    // Initialize quantities to 1 for each item in cart
    final cardProducts = widget.productModels
        .where((product) => widget.cardIds.contains(product.id))
        .toList();

    for (var item in cardProducts) {
      quantities[item.id!] = 1;
    }
  }

  void _removeItem(ProductsModel item) {
    setState(() {
      widget.cardIds.remove(item.id);
      quantities.remove(item.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Item removed from cart'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin: EdgeInsets.all(20),
      ),
    );
  }

  void _removeAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove All Items'),
        content: Text('Are you sure you want to remove all items from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.cardIds.clear();
                quantities.clear();
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Cart cleared'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  margin: EdgeInsets.all(20),
                ),
              );
            },
            child: Text('Remove All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _increaseQuantity(int productId) {
    setState(() {
      quantities[productId] = (quantities[productId] ?? 1) + 1;
    });
  }

  void _decreaseQuantity(int productId) {
    setState(() {
      if ((quantities[productId] ?? 1) > 1) {
        quantities[productId] = (quantities[productId] ?? 1) - 1;
      }
    });
  }

  double _calculateTotal(List<ProductsModel> cardProducts) {
    double total = 0;
    for (var item in cardProducts) {
      total += (item.price ?? 0) * (quantities[item.id] ?? 1);
    }
    return total;
  }

  void _finishOperation(List<ProductsModel> cardProducts) {
    if (cardProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Your cart is empty'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(20),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Items: ${cardProducts.length}'),
            SizedBox(height: 8),
            Text(
              'Total Amount: \$${_calculateTotal(cardProducts).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(height: 12),
            Text('Proceed with payment?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              // Clear cart after purchase
              setState(() {
                widget.cardIds.clear();
                quantities.clear();
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Purchase completed successfully!'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  margin: EdgeInsets.all(20),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardProducts = widget.productModels
        .where((product) => widget.cardIds.contains(product.id))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Cart', style: TextStyle(color: Colors.black)),
        leadingWidth: 24,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (cardProducts.isNotEmpty)
            TextButton.icon(
              onPressed: _removeAll,
              icon: Icon(Icons.delete_sweep, color: Colors.red),
              label: Text('Remove All', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cardProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_checkout_rounded,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty now.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: cardProducts.length,
                    itemBuilder: (context, index) {
                      final item = cardProducts[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),
                // Total and Finish Operation section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_calculateTotal(cardProducts).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _finishOperation(cardProducts),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Finish Operation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(ProductsModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Colors.grey[100],
              child: Image.network(
                item.image!,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  item.category!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price?.toStringAsFixed(2) ?? "0.00"}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    // Quantity controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _decreaseQuantity(item.id!),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.remove, size: 18),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Text(
                              '${quantities[item.id] ?? 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _increaseQuantity(item.id!),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.add, size: 18),
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

          // Delete button
          IconButton(
            onPressed: () => _removeItem(item),
            icon: Icon(Icons.delete_outline, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
