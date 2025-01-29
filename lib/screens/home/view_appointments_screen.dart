// lib/screens/user/view_appointments_screen.dart

import 'package:carcare/screens/services/appointment_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewAppointmentsScreen extends StatelessWidget {
  final AppointmentService _appointmentService = AppointmentService();

  ViewAppointmentsScreen({Key? key}) : super(key: key);

  String formatDate(dynamic date) {
    if (date == null) return 'Not set';
    if (date is Timestamp) {
      return DateFormat('EEE, MMM d, yyyy').format(date.toDate());
    }
    return date.toString();
  }

  bool _canCancelAppointment(Timestamp appointmentDate) {
    final appointmentDateTime = appointmentDate.toDate();
    final now = DateTime.now();
    final difference = appointmentDateTime.difference(now);
    return difference.inHours > 24;
  }

  Future<void> _deleteAppointment(BuildContext context, String appointmentId) async {
    try {
      await _appointmentService.deleteAppointment(appointmentId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting appointment: $e')),
        );
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentService.getAppointmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No appointments yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Book your first appointment now!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final appointmentId = doc.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatDate(data['appointment_date']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Text('Time: ${data['appointment_time'] ?? 'Not set'}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRow(Icons.person_outline, 'Name', data['name']),
                          _buildRow(Icons.phone_outlined, 'Phone', data['phone_number']),
                          _buildRow(Icons.credit_card_outlined, 'Card Number', data['card_number']),
                          _buildRow(Icons.car_repair, 'Service ID', data['service_id']),
                          _buildRow(Icons.directions_car_outlined, 'Car Type', data['car_type']),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildChip('Payment', data['payment_status'], Colors.green, Colors.red),
                                _buildChip('Status', data['service_status'], Colors.blue, Colors.orange),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (data['service_status'] == 'Booked')
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                              onPressed: () {
                                  _showDeleteConfirmation(context, appointmentId, data['appointment_date']);
                                 },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Cancel Appointment'),
                              ),
                            ),
                          _buildRow(Icons.check_circle_outline, 'Approval Status', data['approval_status']),
                          if (data['approval_status'] == 'rejected')
                            _buildRow(Icons.error_outline, 'Rejection Reason', data['rejection_reason']),
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

  Widget _buildRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$label: ${value ?? 'Not provided'}'),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? value, Color successColor, Color failureColor) {
    final bool isSuccess = value?.toLowerCase() == 'paid' || value?.toLowerCase() == 'completed';
    return Chip(
      label: Text(
        '$label: ${value ?? 'Unknown'}',
        style: TextStyle(color: isSuccess ? successColor : failureColor),
      ),
      backgroundColor: isSuccess ? successColor.withOpacity(0.1) : failureColor.withOpacity(0.1),
    );
  }

void _showDeleteConfirmation(BuildContext context, String appointmentId, Timestamp appointmentDate) {
  if (!_canCancelAppointment(appointmentDate)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointments cannot be cancelled within 24 hours of scheduled time'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
     
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(context, appointmentId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      );
    },
  );
}

  // ignore: unused_element
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'booked':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
