import 'package:academichub/auth/auth_service.dart';
import 'package:academichub/auth/views/login.dart';
import 'package:flutter/material.dart';
import 'package:academichub/utilities/design.dart';
import 'package:flutter/gestures.dart';
import 'package:academichub/dashboard/views/dashboard_page.dart';


class RegisterPage extends StatefulWidget { // Renamed from Register
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState(); // Renamed state
}

class _RegisterPageState extends State<RegisterPage> { // Renamed state
  final TextEditingController registerEmailCtrl = TextEditingController();
  final TextEditingController registerPasswordCtrl = TextEditingController();
  final TextEditingController registerFirstNameCtrl = TextEditingController(); // Changed to FirstName
  final TextEditingController registerSurnameCtrl = TextEditingController();   // Added Surname
  bool _obscure = true;

  void register() async {
    final auth = AuthService();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await auth.signUpWithEmailPassword(
        registerEmailCtrl.text.trim(),
        registerPasswordCtrl.text.trim(),
        registerFirstNameCtrl.text.trim(),
        registerSurnameCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context); // remove loading spinner

      // ✅ Navigate to dashboard directly
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // remove loading spinner
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Registration Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  @override
  void dispose() {
    registerEmailCtrl.dispose();
    registerPasswordCtrl.dispose();
    registerFirstNameCtrl.dispose();
    registerSurnameCtrl.dispose(); // Dispose surname controller
    // registerPhoneCtrl.dispose(); // Uncomment if you still use a phone field
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed background to white as per image
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // Adjusted space from top
                const Text(
                  'Join us today!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                // Circular image from assets
                Container(
                  width: 200, // Adjust size as needed
                  height: 200, // Adjust size as needed
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/register.png', // Your asset image path
                      fit: BoxFit.cover, // Ensures the image covers the circular area
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // First Name and Surname in a Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: registerFirstNameCtrl,
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Space between fields
                    Expanded(
                      child: TextField(
                        controller: registerSurnameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Surname',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Email Address
                TextField(
                  controller: registerEmailCtrl,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password
                TextField(
                  controller: registerPasswordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Blue background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      elevation: 0, // No shadow
                    ),
                    child: const Text(
                      'Sign Up', // Corrected text
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Sign In button (from the image)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue, // Text color
                      side: const BorderSide(color: Colors.blue), // Blue border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign In', // Corrected text
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}