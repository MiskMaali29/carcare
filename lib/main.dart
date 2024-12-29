// lib/main.dart

import 'package:carcare/screens/auth/company_login_screen.dart';
import 'package:carcare/screens/auth/company_signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Authentication screens
import 'screens/auth/login_screen.dart';              // Customer login
import 'screens/auth/register_screen.dart';           // Customer signup


// Main screens
import 'screens/home/welcome_screen.dart';            // Welcome screen
import 'screens/home/home_screen.dart';               // Customer home
import 'screens/company/company_dashboard_screen.dart'; // Company dashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF026DFE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF026DFE),
        ),
      ),
      // Start with welcome screen
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login_customer': (context) => const LoginScreen(),
        '/login_company': (context) => const CompanyLoginScreen(),
        '/signup': (context) => const RegisterScreen(),
        '/company_signup': (context) => const CompanyRegisterScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes that need parameters
        switch (settings.name) {
          case '/home':
            final username = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => HomeScreen(
                username: username ?? 'User',
              ),
            );
          
          case '/company_dashboard':
            final username = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => CompanyDashboardScreen(
                username: username ?? 'Company',
              ),
            );

          default:
            // Handle 404
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Page Not Found'),
                  backgroundColor: const Color(0xFF026DFE),
                ),
                body: const Center(
                  child: Text(
                    'The requested page was not found.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}