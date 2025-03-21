// lib/main.dart

import 'package:carcare/screens/auth/company_login_screen.dart';
import 'package:carcare/screens/auth/company_signup_screen.dart';
import 'package:carcare/screens/company/CompanyServiceHistoryScreen.dart';
import 'package:carcare/screens/company/company_view_appointments_screen.dart';
import 'package:carcare/screens/home/CustomerServiceHistoryScreen.dart';
import 'package:carcare/screens/home/setting_screen.dart';
import 'package:carcare/screens/home/view_appointments_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import 'firebase_options.dart';
import 'screens/company/company_dashboard_screen.dart';
import 'screens/company/manage_services_screen.dart';

// Authentication screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

// Main screens
import 'screens/home/welcome_screen.dart';
import 'screens/home/home_screen.dart';


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
        // Add more theme customization
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF026DFE),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF026DFE),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // Start with welcome screen or check auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          
          // If not logged in, show welcome screen
          if (!snapshot.hasData) {
            return const WelcomeScreen();
          }
          
          // Check user type and redirect accordingly
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('companies')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, companySnapshot) {
              if (companySnapshot.hasData && companySnapshot.data!.exists) {
                // User is a company
                return CompanyDashboardScreen(
                  username: companySnapshot.data!.get('company_name') ?? 'Company',
                );
              } else {
                // User is a customer
                return HomeScreen(username: snapshot.data!.email ?? 'User');
              }
            },
          );
        },
      ),
      routes: {
      ' /welcome': (context) => const WelcomeScreen(),
        '/login_customer': (context) => const LoginScreen(),
        '/login_company': (context) => const CompanyLoginScreen(),
        '/signup': (context) => const RegisterScreen(),
        '/company_signup': (context) => const CompanyRegisterScreen(),
        '/company_appointments': (context) => const CompanyViewAppointmentsScreen(),
        '/user_appointments': (context) =>  ViewAppointmentsScreen(),
        '/manage_services': (context) => const ManageServicesScreen(),
        '/company_history': (context) => const CompanyHistoryScreen(),
        '/about_us': (context) => const AboutUsScreen(),
        '/customer_history': (context) => CustomerServiceHistoryScreen(
        userId: FirebaseAuth.instance.currentUser!.uid,
      ),

 
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
      // Add error handling
      builder: (context, child) {
        return Material(
          child: Stack(
            children: [
              child!,
              // You can add global error handling or overlays here
            ],
          ),
        );
      },
    );
  }
}