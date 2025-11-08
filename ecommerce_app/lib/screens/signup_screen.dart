import 'package:ecommerce_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
// 1. Firebase Authentication import
import 'package:firebase_auth/firebase_auth.dart';
// 2. Firestore import to save user roles
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 3. Form key to validate the form
  final _formKey = GlobalKey<FormState>();

  // 4. Controllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 5. Loading state for spinner
  bool _isLoading = false;

  // 6. Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // 7. Dispose controllers when widget is removed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 8. Sign-up function with role assignment
  Future<void> _signUp() async {
    // 8a. Validate the form
    if (!_formKey.currentState!.validate()) return;

    // 8b. Set loading to true to show spinner
    setState(() => _isLoading = true);

    try {
      // 8c. Create a new user with Firebase Auth
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 8d. If user is created successfully, add user info to Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text.trim(), // Save email
          'role': 'user', // Default role is 'user'
          'createdAt': FieldValue.serverTimestamp(), // Timestamp
        });
      }

      // 8e. Navigation is handled by AuthWrapper automatically

    } on FirebaseAuthException catch (e) {
      // 8f. Handle specific Firebase errors
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      }

      // 8g. Show error message as SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // 8h. Print other unexpected errors
      print(e);
    } finally {
      // 8i. Stop loading spinner
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 9. Scaffold provides basic screen layout
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'), // 9a. AppBar title
      ),
      // 10. SingleChildScrollView prevents overflow when keyboard is open
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 10a. Padding around form
          child: Form(
            key: _formKey, // 10b. Assign the form key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 10c. Center contents
              children: [
                const SizedBox(height: 20), // 10d. Spacer

                // 11. Email input field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress, // Shows '@' key
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16), // 12. Spacer

                // 13. Password input field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Hides password
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20), // 14. Spacer before button

                // 15. Sign Up button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)), // Full width
                  onPressed: _signUp, // Calls the _signUp function
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text('Sign Up'), // Shows spinner if loading
                ),

                const SizedBox(height: 10), // 16. Spacer

                // 17. Navigate to login screen
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
