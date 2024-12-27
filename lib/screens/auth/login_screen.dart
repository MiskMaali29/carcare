import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.loginUser(
          emailOrUsername: _emailOrUsernameController.text,
          password: _passwordController.text,
        );
       Navigator.pushReplacementNamed(
       context,
      '/home',
  arguments: _emailOrUsernameController.text, // Pass the username or email
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
        title:const Text('Login'),
        centerTitle: true,
        backgroundColor:const Color(0xFF026DFE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Add a logo
            Center(
              child: Image.asset(
                'assets/images/welcom100.png', // Replace with your logo path
                height: 120,
                width: 120,
              ),
            ),
           const SizedBox(height: 30),
            Text(
              'Welcome Back!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
           const SizedBox(height: 10),
            Text(
              'Login to your account to continue.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Login Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username/Email Field
                  TextFormField(
                    controller: _emailOrUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Username or Email',
                      hintText: 'Enter your username or email',
                      prefixIcon:const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username or email';
                      }
                      return null;
                    },
                  ),
                 const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon:const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                 const SizedBox(height: 10),

                  // Forget Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Add navigation to reset password screen
                        ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                            content: Text('Reset Password is under construction.'),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF026DFE),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                 const SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
  onPressed: _isLoading ? null : _login,
  style: ElevatedButton.styleFrom(
    backgroundColor:const Color(0xFF026DFE), // Updated property
    padding:const EdgeInsets.symmetric(vertical: 14),
    minimumSize:const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: _isLoading
      ? const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        )
      :const Text(
          'Login',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
),

                 const SizedBox(height: 20),

                  // Signup Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     const Text(
                        'Don’t have an account?',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child:const Text(
                          'Sign Up now',
                          style: TextStyle(
                            color: Color(0xFF026DFE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
