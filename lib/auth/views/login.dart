import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:academichub/auth/auth_service.dart';
import 'package:academichub/auth/views/register.dart';
import 'package:academichub/utilities/design.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final design = Design();
  final TextEditingController loginEmailCtrl = TextEditingController();
  final TextEditingController loginPasswordCtrl = TextEditingController();
  bool _obscure = true;

  void login() async {
    final _auth = AuthService();
    try {
      await _auth.signInWithEmailPassword(
        loginEmailCtrl.text,
        loginPasswordCtrl.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(title: Text(e.toString())),
      );
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
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 16),

                Text('Welcome to', style: design.subtitleText),
                Text('Cachingg', style: design.titleText),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 2,
                  width: 300,
                  color: Colors.white,
                ),

                Text('Sign In', style: design.subtitleText),
                const SizedBox(height: 24),

                // — Email label above field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email Address',
                    style: design.contentText.copyWith(color: Colors.grey[600]),
                  ),
                ),
                TextField(
                  controller: loginEmailCtrl,
                  style: design.contentText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'abc@example.com',                                     // ← placeholder
                    hintStyle: design.contentText.copyWith(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // — Password label above field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: design.contentText.copyWith(color: Colors.grey[600]),
                  ),
                ),
                TextField(
                  controller: loginPasswordCtrl,
                  obscureText: _obscure,
                  style: design.contentText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Enter your password',                                             // ← placeholder
                    hintStyle: design.contentText.copyWith(color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    // removed labelText
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // — Sign In button with black text
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: design.secondaryButton,
                      foregroundColor: Colors.black,              // ← button text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: Text('Sign In', style: design.contentText),
                  ),
                ),
                const SizedBox(height: 12),

                RichText(
                  text: TextSpan(
                    text: "I'm a new user. ",
                    style: design.captionText.copyWith(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: design.captionText.copyWith(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Register()),
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