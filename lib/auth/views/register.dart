import 'package:academichub/auth/auth_service.dart';
import 'package:academichub/auth/views/login.dart';
import 'package:flutter/material.dart';
import 'package:academichub/utilities/design.dart';
import 'package:flutter/gestures.dart';


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final design = Design();
  final TextEditingController registerEmailCtrl = TextEditingController();
  final TextEditingController registerPasswordCtrl = TextEditingController();
  final TextEditingController registerNameCtrl = TextEditingController();
  final TextEditingController registerPhoneCtrl = TextEditingController();
  bool _obscure = true;

  void register() async {
    final _auth = AuthService();

    try {
      await _auth.signUpWithEmailPassword(registerEmailCtrl.text, registerPasswordCtrl.text, registerNameCtrl.text, registerPhoneCtrl.text);
      Navigator.pop(context);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(e.toString()),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: design.primaryButton,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // logo
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 16),

                // Welcome title
                Text('Welcome to', style: design.subtitleText),
                Text('Cachingg',    style: design.titleText),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 2, width: 300,
                  color: Colors.white,
                ),

                // Sign Up header
                Text('Sign Up', style: design.subtitleText),
                const SizedBox(height: 24),

                // Full Name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Full Name',
                    style: design.contentText.copyWith(color: Colors.grey[600]),
                  ),
                ),
                TextField(
                  controller: registerNameCtrl,
                  style: design.contentText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Your Name',
                    hintStyle: design.contentText.copyWith(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Address
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email Address',
                    style: design.contentText.copyWith(color: Colors.grey[600]),
                  ),
                ),
                TextField(
                  controller: registerEmailCtrl,
                  style: design.contentText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'XXX@email.com',
                    hintStyle: design.contentText.copyWith(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Phone Number',
                    style: design.contentText.copyWith(color: Colors.grey[600]),
                  ),
                ),
                TextField(
                  controller: registerPhoneCtrl,
                  style: design.contentText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_outlined),
                    hintText: '0123456789',
                    hintStyle: design.contentText.copyWith(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password',
                    style: design.contentText.copyWith(color: Colors.grey[600]),
                  ),
                ),
                TextField(
                  controller: registerPasswordCtrl,
                  obscureText: _obscure,
                  style: design.contentText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Enter your password',
                    hintStyle: design.contentText.copyWith(color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sign Up button
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: design.secondaryButton,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: Text('Sign Up', style: design.contentText),
                  ),
                ),
                const SizedBox(height: 12),

                // Sign In link
                RichText(
                  text: TextSpan(
                    text: 'Already have an account. ',
                    style: design.captionText.copyWith(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: design.captionText.copyWith(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Text('Cachingg©', style: design.captionText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}