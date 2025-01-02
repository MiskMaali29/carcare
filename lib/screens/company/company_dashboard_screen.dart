import 'package:carcare/screens/company/CompanyServiceHistoryScreen.dart';
import 'package:carcare/screens/home/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyDashboardScreen extends StatefulWidget {
  final String username;
  const CompanyDashboardScreen({Key? key, required this.username}) : super(key: key);

  @override
  _CompanyDashboardScreenState createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Custom AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF026DFE).withOpacity(0.9),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Welcome, ${widget.username}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildGlassStatsCard('Total Appointments', '10'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGlassStatsCard('Services Offered', '5'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGlassStatsCard('Total Clients', '8'),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Buttons in the middle of the page
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  _buildActionButton(
                    label: 'Manage Services',
                    onPressed: () {
                      Navigator.pushNamed(context, '/manage_services');
                    },
                  ),
                  const SizedBox(height: 16), // Space between buttons
                  _buildActionButton(
                    label: 'View Appointments',
                    onPressed: () {
                      Navigator.pushNamed(context, '/company_appointments');
                    },
                  ),
                  const SizedBox(height: 16), // Space between buttons
                  _buildActionButton(
                    label: 'View All History',
                    onPressed: () {
                      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CompanyHistoryScreen(),
  ),
);
                    },
                  ),
                ],
              ),
            ),

            const Spacer(), // Push everything to the center
          ],
        ),
      ),
    );
  }

  Widget _buildGlassStatsCard(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF026DFE),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback onPressed}) {
  return Padding(
    padding: const EdgeInsets.only(top: 20.0), // Adds space from the top
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFE5602).withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size.fromHeight(50), // Make buttons full width
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );
}

  }

