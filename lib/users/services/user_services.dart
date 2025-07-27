// lib/users/services/user_services.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../auth/views/login.dart';
import 'package:academichub/users/models/user_settings.dart';
import 'package:academichub/users/views/edit_profile_page.dart';

class UserSettingsService {
  final FirebaseAuth _auth       = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<UserSettingsItem> getUserSettingsItems({
    required BuildContext context,
    required VoidCallback onLogout,
    required VoidCallback onDelete,
    required VoidCallback onEditComplete,   // ← add this
  }) {
    return [
      UserSettingsItem(
        icon: Icons.edit,
        title: 'Edit Profile',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfilePage()),
          ).then((_) {
            onEditComplete();                  // ← fire the callback
          });
        },
      ),
      UserSettingsItem(
        icon: Icons.delete_forever,
        title: 'Delete Account',
        onTap: onDelete,
        type: UserSettingsItemType.destructive,
      ),
      UserSettingsItem(
        icon: Icons.logout,
        title: 'Log Out',
        onTap: onLogout,
        type: UserSettingsItemType.action,
      ),
    ];
  }

  ///─── Upload profile picture to Storage ──────────────────────────────────
  Future<String> uploadProfilePicture(File imageFile) async {
    final uid = _auth.currentUser!.uid;
    final ref = _storage.ref().child('profile/$uid.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  ///─── Update Firestore with the provided data map ────────────────────────
  Future<void> updateProfileData(Map<String, dynamic> data) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('Users').doc(uid).update(data);
  }

  ///─── Fetch current user's Firestore document data ───────────────────────
  Future<Map<String, dynamic>?> fetchUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('Users').doc(uid).get();
      if (doc.exists) return doc.data();
    }
    return null;
  }

  ///─── Sign out and navigate back to login ────────────────────────────────
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    } catch (e) {
      debugPrint('Logout failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  ///─── Delete account (Firestore doc + Auth user) with confirmation ──────
  Future<void> deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final user = _auth.currentUser;
      final uid  = user?.uid;
      if (uid != null) {
        await _firestore.collection('Users').doc(uid).delete();
        await user!.delete();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Account deletion failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deletion failed: $e')),
      );
    }
  }
}
