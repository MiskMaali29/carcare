import 'package:carcare/screens/feedback/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


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
    if (appointmentData['service_id'] == null) {
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
          return Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
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

  Widget _buildFeedbackButton(Map<String, dynamic> data, String appointmentId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedback')
          .where('appointment_id', isEqualTo: appointmentId)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Feedback Submitted',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: () async {
            DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
                .collection('services')
                .doc(data['service_id'])
                .get();
                
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFeedbackScreen(
                    appointmentId: appointmentId,
                    serviceId: data['service_id'] ?? '',
                    serviceName: (serviceDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown Service',
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.star_rate),
          label: const Text('Leave Feedback'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF026DFE),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service History'),
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getCustomerAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data?.docs ?? [];

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
FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('services')
      .doc(data['service_id'].toString())
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildInfoRow('Service', 'Loading...');
    }

    if (!snapshot.hasData || !snapshot.data!.exists) {
      return _buildInfoRow('Service', 'Service not found');
    }

    final serviceData = snapshot.data!.data() as Map<String, dynamic>;
    return _buildInfoRow(
      'Service',
      serviceData['name'] ?? 'Unnamed Service',
    );
  },
),
                           // Add Note Section
            if (data['service_note'] != null && data['service_note'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 24),
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
                        const Row(
                          children: [
                            Icon(
                              Icons.note_alt,
                              size: 20,
                              color: Color(0xFF026DFE),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Service Note:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF026DFE),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['service_note'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

                          if (data['approval_status'] == 'rejected')
                            _buildInfoRow(
                              'Rejection Reason', 
                              data['rejection_reason'] ?? 'No reason provided',
                              isError: true
                            ),
                          const SizedBox(height: 16),
                          if (data['service_status'] == 'Completed')
                            Center(child: _buildFeedbackButton(data, doc.id)),
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