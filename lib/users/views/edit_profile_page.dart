import 'dart:io';

import 'package:academichub/users/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  late TextEditingController _firstNameCtrl;
  late TextEditingController _surnameCtrl;
  late TextEditingController _ageCtrl;
  String? _gender;
  late TextEditingController _aboutCtrl;

  bool _loading = false;
  bool _isDirty = false;

  bool get _hasName =>
      _firstNameCtrl.text.trim().isNotEmpty && _surnameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController()..addListener(_markDirty);
    _surnameCtrl = TextEditingController()..addListener(_markDirty);
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
        _firstNameCtrl.text = data['firstName'] ?? '';
        _surnameCtrl.text   = data['surname'] ?? '';
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
        'firstName': _firstNameCtrl.text.trim(),
        'surname':   _surnameCtrl.text.trim(),
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
    _firstNameCtrl.dispose();
    _surnameCtrl.dispose();
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

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter first name' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _surnameCtrl,
                        decoration: const InputDecoration(labelText: 'Surname'),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter surname' : null,
                      ),
                    ),
                  ],
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
