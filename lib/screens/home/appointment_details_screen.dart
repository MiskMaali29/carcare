import 'package:carcare/screens/services/appointment_service.dart';
import 'package:flutter/material.dart';

import '../../models/appointment.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment; // Pass the Appointment object

  AppointmentDetailsScreen({Key? key, required this.appointment})
      : super(key: key);

  final _appointmentService = AppointmentService(); // Service to delete/update

  Future<void> _deleteAppointment(BuildContext context) async {
    try {
      await _appointmentService.deleteAppointment(appointment.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted successfully!')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${appointment.name}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Card Number: ${appointment.cardNumber}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Phone Number: ${appointment.phoneNumber}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Appointment Date: ${appointment.appointmentDate}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Appointment Time: ${appointment.appointmentTime}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Payment Status: ${appointment.paymentStatus}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Service Status: ${appointment.serviceStatus}',
                style: const TextStyle(fontSize: 16)),

                 if (appointment.serviceNote != null && appointment.serviceNote!.isNotEmpty) 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service Note:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointment.serviceNote!,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigation to Edit Screen (can be added later)
                  },
                  child: const Text('Edit Booking'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _deleteAppointment(context),
                  style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFFFE5602)
                    ),
                  child: const Text('Delete Booking'),
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
