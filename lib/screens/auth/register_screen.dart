import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.registerUser(
          username: _usernameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: _usernameController.text.trim(),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/images/welcom100.png',
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create Your Account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please fill in the form to register',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_usernameController, 'Username', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(_fullNameController, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Email', Icons.email, isEmail: true),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneController, 'Phone', Icons.phone, isPhone: true),
                  const SizedBox(height: 16),
                  _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _confirmPasswordController,
                    'Confirm Password',
                    Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _termsAccepted,
                    onChanged: (value) => setState(() => _termsAccepted = value ?? false),
                    title: GestureDetector(
                      onTap: () {
                        // Navigate to Terms & Conditions
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: const Text(
                        'I agree with the Terms & Conditions',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF026DFE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
              ? TextInputType.phone
              : TextInputType.text,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (isPhone && !RegExp(r'^\d{10,15}$').hasMatch(value)) {
          return 'Enter a valid phone number';
        }
        if (isPassword && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (label == 'Confirm Password' && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
