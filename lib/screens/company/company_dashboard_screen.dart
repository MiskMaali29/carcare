import 'package:carcare/screens/company/CompanyServiceHistoryScreen.dart';
import 'package:carcare/screens/home/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyDashboardScreen extends StatefulWidget {
  final String username;
  const CompanyDashboardScreen({Key? key, required this.username}) : super(key: key);

  @override
  _CompanyDashboardScreenState createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   final FirebaseAuth _auth = FirebaseAuth.instance;

   Future<Map<String, dynamic>> _fetchDashboardStats() async {
      try {
      // Get current company ID
      final String? companyId = _auth.currentUser?.uid;
      if (companyId == null) {
        throw Exception('No authenticated user');
      }

      // Get appointments
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .get();

      // Calculate total appointments
      final totalAppointments = appointmentsSnapshot.docs.length;

      // Get unique clients
      final uniqueClients = appointmentsSnapshot.docs
          .map((doc) => doc.data()['user_id'] as String?)
          .where((id) => id != null)
          .toSet();

      // Get services
      final servicesSnapshot = await _firestore
          .collection('services')
          .get();

      return {
        'totalAppointments': totalAppointments,
        'totalServices': servicesSnapshot.docs.length,
        'totalClients': uniqueClients.length,
      };
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      rethrow;
    }
  }




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

           
            // Stats Cards with FutureBuilder
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchDashboardStats(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildGlassStatsCard('Total Appointments', '0'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildGlassStatsCard('Services Offered', '0'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildGlassStatsCard('Total Clients', '0'),
                        ),
                      ],
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final stats = snapshot.data!;
                  return Row(
                    children: [
                      Expanded(
                        child: _buildGlassStatsCard(
                          'Total Appointment',
                          stats['totalAppointments'].toString(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGlassStatsCard(
                          'Services  Offered',
                          stats['totalServices'].toString(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGlassStatsCard(
                          'Total Clients',
                          stats['totalClients'].toString(),
                        ),
                      ),
                    ],
                  );
                },
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
                  const SizedBox(height: 16), 
                  ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/view_feedback'),
  child: const Text('View Feedback'),
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


// ui for the glass stats card in the dashboard
Widget _buildGlassStatsCard(String title, String value) {
  IconData getCardIcon() {
    switch (title) {
      case 'Total Appointment':
        return Icons.calendar_today;
      case 'Services Offered':
        return Icons.build;
      case 'Total Clients':
        return Icons.people;
      default:
        return Icons.info;
    }
  }

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.5),
          blurRadius: 10,
          offset: const Offset(-4, -4),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF026DFE).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            getCardIcon(),
            color: const Color(0xFFFF6A20),
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF026DFE),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}

// ui for the action button in the dashboard
  Widget _buildActionButton({required String label, required VoidCallback onPressed}) {
  return Padding(
    padding: const EdgeInsets.only(top: 20.0), 
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFE5602).withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size.fromHeight(50), 
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );
}

  }

