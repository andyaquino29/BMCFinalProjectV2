import 'package:flutter/material.dart';
import 'package:ecommerce_app/providers/cart_provider.dart'; // 1. ADD THIS
import 'package:provider/provider.dart'; // 2. ADD THIS

// 1. This is a new StatelessWidget
class ProductDetailScreen extends StatelessWidget {
  // 2. We will pass in the product's data (the map)
  final Map<String, dynamic> productData;

  // 3. We'll also pass the unique product ID (critical for 'Add to Cart' later)
  final String productId;

  // 4. The constructor takes both parameters
  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Extract data from the map for easier use
    final String name = productData['name'];
    final String description = productData['description'];
    final String imageUrl = productData['imageUrl'];
    final double price = productData['price'];

    // 2. ADD THIS LINE: Get the CartProvider
    final cart = Provider.of<CartProvider>(context, listen: false);

    // 3. The main screen widget
    return Scaffold(
      appBar: AppBar(
        // 4. Show the product name in the top bar
        title: Text(name),
      ),

      // 5. This allows scrolling if the description is very long
      body: SingleChildScrollView(
        child: Column(
          // 6. Make children fill the width
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 7. The large product image
            Image.network(
              imageUrl,
              height: 300, // Give it a fixed height
              fit: BoxFit.cover, // Make it fill the space

              // 8. Add the same loading/error builders as the card
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: Icon(Icons.broken_image, size: 100)),
                );
              },
            ),

            // 9. A Padding widget to contain all the text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 10. Product Name (large font)
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 11. Price (large font, different color)
                  Text(
                    '₱${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 12. A horizontal dividing line
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),

                  // 13. The full description
                  Text(
                    'About this item',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5, // Adds line spacing for readability
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 14. The "Add to Cart" button — now functional
                  ElevatedButton.icon(
                    onPressed: () {
                      // NEW LOGIC: Add item to cart
                      cart.addItem(productId, name, price);

                      // Show a confirmation SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
