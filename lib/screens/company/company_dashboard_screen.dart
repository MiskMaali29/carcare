import 'package:carcare/screens/company/CompanyServiceHistoryScreen.dart';
import 'package:carcare/screens/home/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class CompanyDashboardScreen extends StatefulWidget {
  final String username;
  const CompanyDashboardScreen({super.key, required this.username});

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF026DFE).withOpacity(0.1),
              Colors.white.withOpacity(0.8),
            ],
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

         Padding(
  padding: const EdgeInsets.symmetric(horizontal: 22.0),
  child: SizedBox(
    height: 400, // Set a fixed height for the GridView
    child: GridView.count(

    shrinkWrap: true,
    crossAxisCount: 2,
    crossAxisSpacing: 0,
    mainAxisSpacing: 20,
    
    children: [
      _buildCircularButton(
        icon: Icons.build,
        label: 'Manage Services',
        onPressed: () {
          Navigator.pushNamed(context, '/manage_services');
        },
      ),
      _buildCircularButton(
        icon: Icons.calendar_today,
        label: 'View Appointments',
        onPressed: () {
          Navigator.pushNamed(context, '/company_appointments');
        },
      ),
      _buildCircularButton(
        icon: Icons.history,
        label: 'View History',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CompanyHistoryScreen(),
            ),
          );
        },
      ),
      _buildCircularButton(
        icon: Icons.feedback,
        label: 'View Feedback',
        onPressed: () {
          Navigator.pushNamed(context, '/view_feedback');
        },
      ),
    ],
  ),
),
         ),

            const Spacer(), 
          ],
        ),
      ),
    );
  }
Widget _buildCircularButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
   return SizedBox(
     width: 120, // Fixed width for the button
    height: 150, // Fixed height for the button (to accommodate text)
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100, // Fixed width for the circular button
          height: 100, // Fixed height for the circular button
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF026DFE).withOpacity(0.3),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(50), // Circular shape
              child: Center(
                child: Icon(
                  icon,
                  size: 48,
                  color: const Color(0xFFFF6A20).withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), // Spacing between icon and text
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14, // Reduced font size to fit within the space
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2, // Allow text to wrap to a second line if needed
            overflow: TextOverflow.ellipsis, // Handle overflow gracefully
          ),
        ),
      ],
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
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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


  }

