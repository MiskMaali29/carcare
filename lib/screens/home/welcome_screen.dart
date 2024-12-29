// lib/screens/home/welcome_screen.dart

import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _showUserTypeDialog(BuildContext context, bool isLogin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isLogin ? 'Choose User Type' : 'Choose Registration Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    isLogin ? '/login_customer' : '/signup',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF026DFE),
                ),
                child: const Text(
                  'Customer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    isLogin ? '/login_company' : '/company_signup',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF026DFE),
                ),
                child: const Text(
                  'Company',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Circular container at the top
          Positioned(
            top: -150,
            left: -20,
            right: -20,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF026DFE),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 80),
                  child: Image.asset(
                    'assets/images/selectpic.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Your specialized workshop for professional car maintenance and repair',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 24,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF026DFE),
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2.0,
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      'Start Your Journey With Us',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB800),
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4.0,
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Buttons Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _showUserTypeDialog(context, true), // for login
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF026DFE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showUserTypeDialog(context, false), // for signup
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFF026DFE), width: 2),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF026DFE),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}