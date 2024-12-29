// lib/screens/company/company_dashboard_screen.dart

import 'package:flutter/material.dart';

class CompanyDashboardScreen extends StatelessWidget {
  final String username;

  const CompanyDashboardScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
        backgroundColor: const Color(0xFF026DFE),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Hello Dashboard',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}