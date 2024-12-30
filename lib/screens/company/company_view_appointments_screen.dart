// lib/screens/company/company_view_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CompanyViewAppointmentsScreen extends StatelessWidget {
  const CompanyViewAppointmentsScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> getAppointmentsStream() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('appointment_date', descending: true)
        .snapshots();
  }

  // Format date from Timestamp or String
  String formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    if (date is Timestamp) {
      return DateFormat('EEEE, MMMM d, yyyy').format(date.toDate());
    }
    return date.toString();
  }

  // Update appointment status
  Future<void> updateStatus(String appointmentId, String field, String value) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({field: value});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // Show detailed view dialog
  void showDetailsDialog(BuildContext context, Map<String, dynamic> data, String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(data['name'] ?? 'Unknown'),
                  subtitle: const Text('Customer Name'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(data['phone_number'] ?? 'Unknown'),
                  subtitle: const Text('Phone Number'),
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text(data['car_type'] ?? 'Unknown'),
                  subtitle: const Text('Car Type'),
                ),
                ListTile(
                  leading: const Icon(Icons.pin),
                  title: Text(data['chassis_number'] ?? 'Unknown'),
                  subtitle: const Text('Chassis Number'),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(formatDate(data['appointment_date'])),
                  subtitle: Text('Time: ${data['appointment_time'] ?? 'Unknown'}'),
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Payment Status'),
                        value: data['payment_status'] ?? 'Not Paid',
                        items: ['Not Paid', 'Paid'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            updateStatus(appointmentId, 'payment_status', newValue);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Service Status'),
                        value: data['service_status'] ?? 'Booked',
                        items: ['Booked', 'In Progress', 'Completed'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            updateStatus(appointmentId, 'service_status', newValue);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Show payment update dialog
  void showPaymentDialog(BuildContext context, Map<String, dynamic> data, String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Payment Status'),
          content: DropdownButtonFormField<String>(
            value: data['payment_status'] ?? 'Not Paid',
            items: ['Not Paid', 'Paid'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                updateStatus(appointmentId, 'payment_status', newValue);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  // Show service update dialog
  void showServiceDialog(BuildContext context, Map<String, dynamic> data, String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Service Status'),
          content: DropdownButtonFormField<String>(
            value: data['service_status'] ?? 'Booked',
            items: ['Booked', 'In Progress', 'Completed'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                updateStatus(appointmentId, 'service_status', newValue);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Appointments'),
        backgroundColor: const Color(0xFF026DFE),
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

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              final appointmentId = appointments[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${data['name'] ?? 'Unknown'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Phone: ${data['phone_number'] ?? 'Unknown'}'),
                      Text('Car Type: ${data['car_type'] ?? 'Unknown'}'),
                      Text('Chassis Number: ${data['chassis_number'] ?? 'Unknown'}'),
                      Text('Appointment Date: ${formatDate(data['appointment_date'])}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              'Payment: ${data['payment_status'] ?? 'Unknown'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: data['payment_status'] == 'Paid'
                                ? Colors.green
                                : Colors.red,
                          ),
                          Chip(
                            label: Text(
                              'Service: ${data['service_status'] ?? 'Unknown'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: data['service_status'] == 'Completed'
                                ? Colors.blue
                                : Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => showDetailsDialog(context, data, appointmentId),
                            child: const Text('View'),
                          ),
                          TextButton(
                            onPressed: () => showPaymentDialog(context, data, appointmentId),
                            child: const Text('Payment'),
                          ),
                          TextButton(
                            onPressed: () => showServiceDialog(context, data, appointmentId),
                            child: const Text('Service'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}