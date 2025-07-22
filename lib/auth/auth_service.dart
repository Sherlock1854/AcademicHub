import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// SIGN IN
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// SIGN UP
  Future<UserCredential> signUpWithEmailPassword(String email, password, firstName, surname) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Save user with default role: 'user'
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "firstName": firstName,
        "surname": surname,
        "role": "user",
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// FORGOT PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
