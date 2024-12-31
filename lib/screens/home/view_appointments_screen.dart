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
        // Use the AppointmentService stream
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
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 20),
                              const SizedBox(width: 8),
                              Text('Name: ${data['name'] ?? 'Not provided'}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text('Phone: ${data['phone_number'] ?? 'Not provided'}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.credit_card_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text('Card Number: ${data['card_number'] ?? 'Not provided'}'),
                            ],
                          ),
                           const SizedBox(height: 8),
                          Row(
                           children: [
                            const Icon(Icons.car_repair, size: 20),
                             const SizedBox(width: 8),
                             Text('Service ID: ${data['service_id'] ?? 'Not assigned'}'),
                            ],
                          ),
                           const SizedBox(height: 8),
                            Row(
                           children: [
                            const Icon(Icons.directions_car_outlined, size: 20),
                            const SizedBox(width: 8),
                              Text('Car Type: ${data['car_type'] ?? 'Not provided'}'),
                          ],
                            ),
                           const SizedBox(height: 16),
                            // Status Chips
                        //    Row(
                        //    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         ////   children: [
                         //     Chip(
                         //     label: Text(
                        //        'Payment: ${data['payment_status'] ?? 'Not Paid'}',
                        //        style: TextStyle(
                        //        color: (data['payment_status'] == 'Paid') 
                        //          ? Colors.green 
                        //          : Colors.red,
                         //       ),
                        //      ),
                         //     backgroundColor: (data['payment_status'] == 'Paid')
                      //          ? Colors.green.withOpacity(0.1)
                       //         : Colors.red.withOpacity(0.1),
                       //       ),
                     //         Chip(
                       //       label: Text(
                      //          'Status: ${data['service_status'] ?? 'Booked'}',
                       //         style: TextStyle(
                        //        color: _getStatusColor(data['service_status']),
                        //        ),
                       //       ),
                       //       backgroundColor: _getStatusColor(data['service_status'])
                       //         .withOpacity(0.1),
                       //       ),
                       //     ],
                       //     ),
                      //      const SizedBox(height: 16),
                            // Action Buttons
                            if (data['service_status'] == 'Booked') // Only show if appointment is not in progress
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Appointment'),
                                          content: const Text(
                                            'Are you sure you want to delete this appointment?'
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteAppointment(context, appointmentId);
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Cancel Appointment'),
                                ),
                              ],
                            ),
                            Row(
  children: [
    const Icon(Icons.check_circle_outline, size: 20),
    const SizedBox(width: 8),
    Text('Approval Status: ${data['approval_status'] ?? 'Pending'}'),
  ],
),
if (data['approval_status'] == 'rejected') 
  Row(
    children: [
      const Icon(Icons.error_outline, size: 20),
      const SizedBox(width: 8),
      Text('Rejection Reason: ${data['rejection_reason'] ?? 'Not provided'}'),
    ],
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

 // Color _getStatusColor(String? status) {
 //   switch (status) {
  //    case 'Completed':
 //       return Colors.green;
  //    case 'In Progress':
  //      return Colors.orange;
  //    case 'Booked':
 //       return Colors.blue;
  //    default:
   //     return Colors.grey;
//    }
 // }
}