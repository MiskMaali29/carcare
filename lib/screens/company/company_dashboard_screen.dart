// lib/screens/company/company_dashboard_screen.dart

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

  Widget _buildStatsCard(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
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
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.build),
            label: const Text('Manage Services'),
            onPressed: () {
              Navigator.pushNamed(context, '/manage_services');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF026DFE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.visibility),
            label: const Text('View Appointments'),
            onPressed: () {
              Navigator.pushNamed(context, '/company_appointments');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF026DFE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Service'),
            onPressed: () {
              // Add service functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}'),
        backgroundColor: const Color(0xFF026DFE),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              // Stats Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: _buildStatsCard('Total Appointments', totalAppointments.toString())),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatsCard('Services Offered', activeServices.toString())),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatsCard('Total Clients', uniqueClients.toString())),
                  ],
                ),
              ),

              _buildActionButtons(),

              if (_showAppointments) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by Name or ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
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
    );
  }
}