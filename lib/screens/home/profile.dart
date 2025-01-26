import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  bool _isLoading = false;
  bool _isEditing = false;
  bool _hasChanges = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_isEditing && _hasChanges) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save your changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
                await _updateProfile();
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      ) ?? false;
    }
    return true;
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userData = doc.data();
            _fullNameController.text = _userData?['fullName'] ?? '';
            _emailController.text = _userData?['email'] ?? '';
            _phoneController.text = _userData?['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      _showErrorMessage('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter your current password'
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new password'
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                hintText: 'Confirm your new password'
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                _showErrorMessage('Passwords do not match');
                return;
              }
              
              try {
                final user = _auth.currentUser;
                if (user != null) {
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPasswordController.text);
                  
                  Navigator.pop(context);
                  _showErrorMessage('Password updated successfully');
                }
              } on FirebaseAuthException catch (e) {
                String message = 'Error updating password';
                if (e.code == 'wrong-password') {
                  message = 'Current password is incorrect';
                }
                _showErrorMessage(message);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fullName': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
        });

        setState(() {
          _isEditing = false;
          _hasChanges = false;
        });
        _showErrorMessage('Profile updated successfully');
      }
    } catch (e) {
      _showErrorMessage('Error updating profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.username}\'s Profile'),
          backgroundColor: const Color(0xFF026DFE),
          actions: [
            if (!_isLoading)
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    _updateProfile();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage('assets/images/logo192.png'),
                            ),
                            if (_isEditing)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF026DFE),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        enabled: false,
                        prefixIcon: Icons.person,

                        
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        enabled: _isEditing,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter your full name';
                          return null;
                        },
                        onChanged: (value) => setState(() => _hasChanges = true),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        enabled: false,
                        prefixIcon: Icons.email,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        enabled: _isEditing,
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter your phone number';
                          if (!RegExp(r'^\d{10,15}$').hasMatch(value!)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() => _hasChanges = true),
                      ),
                      const SizedBox(height: 20),
                      if (_isEditing)
                        ElevatedButton(
                          onPressed: _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF026DFE),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Change Password'),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[200],
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
    );
  }
}