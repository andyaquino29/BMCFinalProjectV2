// home_screen.dart

// 1. Import core Flutter and Firebase packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 2. ADD THIS IMPORT
import 'package:ecommerce_app/screens/admin_panel_screen.dart'; // 3. ADD THIS
import 'package:ecommerce_app/widgets/product_card.dart'; // 4. ADD THIS IMPORT
import 'package:ecommerce_app/screens/product_detail_screen.dart'; // ✅ ADDED FOR MODULE 7 PART C

// ---------------------------
// MODULE 8 PART E: ADD CART ICON
// ---------------------------
import 'package:ecommerce_app/providers/cart_provider.dart'; // ✅ 1. ADD THIS
import 'package:ecommerce_app/screens/cart_screen.dart'; // ✅ 2. ADD THIS
import 'package:provider/provider.dart'; // ✅ 3. ADD THIS

// 5. Change StatelessWidget to StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // 6. Create the State class
  State<HomeScreen> createState() => _HomeScreenState();
}

// 7. Rename the main class to _HomeScreenState and extend State
class _HomeScreenState extends State<HomeScreen> {
  // 8. A state variable to hold the user's role. Default to 'user'.
  String _userRole = 'user';

  // 9. Get the current user from Firebase Auth
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // 10. This function runs ONCE when the screen is first created
  @override
  void initState() {
    super.initState();
    // 11. Call our function to get the role as soon as the screen loads
    _fetchUserRole();
  }

  // 12. This is our new function to get data from Firestore
  Future<void> _fetchUserRole() async {
    // 13. If no one is logged in, do nothing
    if (_currentUser == null) return;

    try {
      // 14. Go to the 'users' collection, find the document matching the current user's ID
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();

      // 15. If the document exists...
      if (doc.exists && doc.data() != null) {
        // 16. ...call setState() to save the role to our variable
        setState(() {
          _userRole = doc.data()!['role'];
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
      // If there's an error, they'll just keep the 'user' role
    }
  }

  // 17. Move the _signOut function inside this class
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // 18. The build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 19. Use the _currentUser variable we defined
        title: Text(_currentUser != null
            ? 'Welcome, ${_currentUser.email}'
            : 'Home'),
        actions: [
          // ---------------------------
          // MODULE 8 PART E: CART ICON WITH BADGE
          // ---------------------------
          // 1. --- ADD THIS NEW WIDGET ---
          // This is a special, efficient way to use Provider
          Consumer<CartProvider>(
            // 2. The "builder" function rebuilds *only* the icon
            builder: (context, cart, child) {
              // 3. The "Badge" widget adds a small label
              return Badge(
                // 4. Get the count from the provider
                label: Text(cart.itemCount.toString()),
                // 5. Only show the badge if the count is > 0
                isLabelVisible: cart.itemCount > 0,
                // 6. This is the child (our icon button)
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    // 7. Navigate to the CartScreen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // 20. --- THIS IS THE MAGIC ---
          //     This IconButton will only appear IF _userRole == 'admin'
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                // 21. Navigate to AdminPanelScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),

          // 22. The logout button (always visible)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _signOut, // 23. Call our _signOut function
          ),
        ],
      ),

      // 24. REPLACED BODY (Dynamic Product Grid)
      body: StreamBuilder<QuerySnapshot>(
        // 25. This is our query to Firestore
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true) // 26. Show newest first
            .snapshots(),

        // 27. The builder runs every time new data arrives from the stream
        builder: (context, snapshot) {
          // 28. STATE 1: While data is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 29. STATE 2: If an error occurs
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 30. STATE 3: If there's no data (or no products)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }

          // 31. STATE 4: We have data!
          // Get the list of product documents from the snapshot
          final products = snapshot.data!.docs;

          // 32. Use GridView.builder for a 2-column grid
          return GridView.builder(
            padding: const EdgeInsets.all(10.0),

            // 33. This configures the grid layout
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 10, // Horizontal space between cards
              mainAxisSpacing: 10, // Vertical space between cards
              childAspectRatio: 3 / 4, // Makes cards taller than wide
            ),

            itemCount: products.length,
            itemBuilder: (context, index) {
              // 34. Get the data for one product
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;

              // 35. Return our custom ProductCard widget!
              return ProductCard(
                productName: productData['name'],
                price: productData['price'],
                imageUrl: productData['imageUrl'],

                // ✅ MODULE 7 PART C — NEW ADDITION:
                // 36. Add the onTap property to navigate to ProductDetailScreen
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        // 37. Pass product data and Firestore document ID
                        productData: productData,
                        productId: productDoc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
