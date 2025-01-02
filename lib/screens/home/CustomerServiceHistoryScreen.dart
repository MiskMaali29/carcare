import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class CustomerServiceHistoryScreen extends StatefulWidget {
  final String userId;

  const CustomerServiceHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CustomerServiceHistoryScreen> createState() => _CustomerServiceHistoryScreenState();
}

class _CustomerServiceHistoryScreenState extends State<CustomerServiceHistoryScreen> {
  Stream<QuerySnapshot> _getCustomerAppointments() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('user_id', isEqualTo: widget.userId)
        .orderBy('appointment_date', descending: true)
        .snapshots();
  }

  Widget _buildServiceTitle(Map<String, dynamic> appointmentData) {
    developer.log('==== Appointment Data ====');
    developer.log('Service ID: ${appointmentData['service_id']}');
    developer.log('All Fields: ${appointmentData.keys.toList()}');

    if (appointmentData['service_id'] == null) {
      developer.log('No service_id found in appointment');
      return const Text(
        'No Service ID',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.red,
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('services')
          .doc(appointmentData['service_id'].toString())
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (snapshot.hasError) {
          developer.log('Error fetching service: ${snapshot.error}');
          return Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          developer.log('No service found for ID: ${appointmentData['service_id']}');
          return Text(
            'Service not found (ID: ${appointmentData['service_id']})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange,
            ),
          );
        }

        final serviceData = snapshot.data!.data() as Map<String, dynamic>;
        developer.log('==== Service Data ====');
        developer.log('Service Fields: ${serviceData.keys.toList()}');
        developer.log('Service Name: ${serviceData['name']}');

        return Text(
          serviceData['name'] ?? 'Unnamed Service',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building CustomerServiceHistoryScreen for user: ${widget.userId}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service History'),
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getCustomerAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            developer.log('Error in StreamBuilder: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data?.docs ?? [];
          developer.log('Found ${appointments.length} appointments');

          if (appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No service history found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final doc = appointments[index];
              final data = doc.data() as Map<String, dynamic>;
              developer.log('Processing appointment ${index + 1}: ${doc.id}');

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: _buildServiceTitle(data),
                  subtitle: Text(formatDate(data['appointment_date'])),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(data['service_status'] ?? '').withOpacity(0.1),
                    child: Icon(
                      Icons.build,
                      color: _getStatusColor(data['service_status'] ?? ''),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Status', data['service_status'] ?? 'N/A'),
                          _buildInfoRow('Payment', data['payment_status'] ?? 'Not Paid'),
                          _buildInfoRow('Amount', '\$${data['amount_paid'] ?? '0.00'}'),
                          _buildInfoRow('Car Type', data['car_type'] ?? 'N/A'),
                          _buildInfoRow('Appointment Time', data['appointment_time'] ?? 'N/A'),
                          _buildInfoRow('Service ID', data['service_id']?.toString() ?? 'N/A'),
                          if (data['approval_status'] == 'rejected')
                            _buildInfoRow(
                              'Rejection Reason', 
                              data['rejection_reason'] ?? 'No reason provided',
                              isError: true
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      if (timestamp is Timestamp) {
        final DateTime date = timestamp.toDate();
        final DateFormat formatter = DateFormat('MMM d, yyyy - hh:mm a');
        return formatter.format(date);
      }
      return timestamp.toString();
    } catch (e) {
      developer.log('Error formatting date: $e');
      return 'N/A';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'booked':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isError ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}