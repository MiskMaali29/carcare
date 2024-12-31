
import 'package:carcare/screens/home/welcome_screen.dart';
import 'package:carcare/screens/services/appointment_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyDashboardScreen extends StatefulWidget {
  final String username;
  const CompanyDashboardScreen({Key? key, required this.username}) : super(key: key);

  @override
  _CompanyDashboardScreenState createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AppointmentService _appointmentService = AppointmentService();
  String _searchQuery = '';
  bool _showAppointments = false;

  Stream<QuerySnapshot> getAppointmentsStream() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('appointment_date', descending: true)
        .snapshots();
  }




  Widget _buildAppointmentTable(List<QueryDocumentSnapshot> appointments) {
    // Filter appointments based on search query
    final filteredAppointments = appointments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final searchFields = [
        doc.id,
        data['name']?.toString() ?? '',
        data['chassis_number']?.toString() ?? '',
      ].map((e) => e.toLowerCase()).toList();
      
      return _searchQuery.isEmpty || 
        searchFields.any((field) => field.contains(_searchQuery.toLowerCase()));
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Phone Number')),
          DataColumn(label: Text('Car Type')),
          DataColumn(label: Text('Chassis Number')),
          DataColumn(label: Text('Appointment Date')),
          DataColumn(label: Text('Payment Status')),
          DataColumn(label: Text('Service Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: filteredAppointments.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DataRow(
            cells: [
              DataCell(Text(doc.id.substring(0, 6))),
              DataCell(Text(data['name'] ?? '')),
              DataCell(Text(data['phone_number'] ?? '')),
              DataCell(Text(data['car_type'] ?? '')),
              DataCell(Text(data['chassis_number'] ?? '')),
              DataCell(Text(data['appointment_date'] ?? '')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: data['payment_status'] == 'Paid' 
                        ? Colors.green[100] 
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['payment_status'] ?? 'Not Paid',
                    style: TextStyle(
                      color: data['payment_status'] == 'Paid' 
                          ? Colors.green[900] 
                          : Colors.red[900],
                    ),
                  ),
                ),
              ),
              DataCell(
                DropdownButton<String>(
                  value: data['service_status'] ?? 'Booked',
                  items: ['Booked', 'In Progress', 'Completed']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    _appointmentService.updateAppointment(
                      doc.id,
                      {'service_status': newValue},
                    );
                  },
                ),
              ),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Edit functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _appointmentService.deleteAppointment(doc.id);
                    },
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: getAppointmentsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final appointments = snapshot.data?.docs ?? [];
            final totalAppointments = appointments.length;
            final activeServices = appointments
                .where((doc) => (doc.data() as Map<String, dynamic>)['service_status'] == 'In Progress')
                .length;
            final uniqueClients = appointments
                .map((doc) => (doc.data() as Map<String, dynamic>)['user_id'])
                .toSet()
                .length;

            return Column(
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

                // Stats Cards with Glass Effect
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildGlassStatsCard('Total Appointments', totalAppointments.toString()),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGlassStatsCard('Services Offered', activeServices.toString()),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildGlassStatsCard('Total Clients', uniqueClients.toString()),
                      ),
                    ],
                  ),
                ),

                // Centered Action Buttons
                Center(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildActionButton(
                        'Manage Services',
                        Icons.build,
                        () => Navigator.pushNamed(context, '/manage_services'),
                      ),
                      _buildActionButton(
                        'View Appointments',
                        Icons.visibility,
                        () => Navigator.pushNamed(context, '/company_appointments'),
                      ),
                     
                    ],
                  ),
                ),

                if (_showAppointments) ...[
                  // Search Bar with Glass Effect
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by Name or ID',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildAppointmentTable(appointments),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
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
          color: Colors.white.withOpacity(0.1),
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, {bool isSecondary = false}) {
  return ElevatedButton.icon(
    icon: Icon(icon),
    label: Text(label),
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: isSecondary ? Colors.white : const Color(0xFFFE5602),
      foregroundColor: isSecondary ? Colors.black87 : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
}
