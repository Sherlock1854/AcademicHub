// lib/users/views/edit_profile_page.dart

import 'dart:io';

import 'package:academichub/users/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Replace with your actual blue if you have a constant:
const Color functionBlue = Color(0xFF006FF9);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserSettingsService();

  File? _pickedImage;
  String? _photoUrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  String? _gender;
  late TextEditingController _aboutCtrl;

  bool _loading = false;
  bool _isDirty = false;

  bool get _hasName => _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController()..addListener(_markDirty);
    _ageCtrl = TextEditingController()..addListener(_markDirty);
    _aboutCtrl = TextEditingController()..addListener(_markDirty);
    _loadExistingData();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _loadExistingData() async {
    final data = await _service.fetchUserData();
    if (data != null) {
      setState(() {
        _photoUrl       = data['photoUrl'];
        _nameCtrl.text  = data['fullName'] ?? '';
        _ageCtrl.text   = data['age']?.toString() ?? '';
        _gender         = data['gender'];
        _aboutCtrl.text = data['about'] ?? '';
        _isDirty        = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() {
        _pickedImage = File(result.path);
        _isDirty     = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty || _loading) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Discard them and leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard == true;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String? url = _photoUrl;
      if (_pickedImage != null) {
        url = await _service.uploadProfilePicture(_pickedImage!);
      }

      final updateData = {
        'fullName': _nameCtrl.text.trim(),
        'age':      int.tryParse(_ageCtrl.text.trim()) ?? 0,
        'gender':   _gender,
        'about':    _aboutCtrl.text.trim(),
        if (url != null) 'photoUrl': url,
      };

      await _service.updateProfileData(updateData);

      if (mounted) {
        setState(() => _isDirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Profile update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          // Removed custom colors so it uses your imported theme
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_photoUrl != null
                        ? NetworkImage(_photoUrl!) as ImageProvider
                        : null),
                    child: (_pickedImage == null && _photoUrl == null)
                        ? const Icon(Icons.person, size: 50, color: Colors.white70)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Tap avatar to change profile'),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _ageCtrl,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                  (v == null || int.tryParse(v.trim()) == null)
                      ? 'Enter a valid age'
                      : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  items: const [
                    'Male',
                    'Female',
                    'Not Prefer to Say',
                  ].map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(
                      g,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() {
                    _gender = v;
                    _isDirty = true;
                  }),
                  validator: (v) => v == null ? 'Select gender' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _aboutCtrl,
                  decoration: const InputDecoration(labelText: 'About Me'),
                  maxLines: 4,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: (_loading || !_hasName) ? null : _saveProfile,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: functionBlue,
                side: const BorderSide(color: functionBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: functionBlue)
                  : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
