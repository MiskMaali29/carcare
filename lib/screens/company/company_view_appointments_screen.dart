import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class CompanyViewAppointmentsScreen extends StatelessWidget {
  final NotificationService _notificationService = NotificationService();
  
  CompanyViewAppointmentsScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> getAppointmentsStream() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      if (timestamp is Timestamp) {
        final DateTime date = timestamp.toDate();
        final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
        return formatter.format(date);
      }
      return timestamp.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getStatusColor(String status, String type) {
    if (type == 'payment') {
      return status == 'Paid' ? Colors.green : Colors.red;
    } else if (type == 'approval') {
      switch (status.toLowerCase()) {
        case 'approved':
          return Colors.green;
        case 'rejected':
          return Colors.red;
        default:
          return Colors.orange;
      }
    } else {
      switch (status.toLowerCase()) {
        case 'completed':
          return Colors.green;
        case 'in progress':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _sendNotification(String userId, String serviceId, String serviceName, String status, String? rejectionReason) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final fcmToken = userDoc.data()?['fcmToken'];

      // Create notification in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'user_id': userId,
        'service_id': serviceId,
        'type': rejectionReason != null ? 'rejection' : 'status_update',
        'service_status': status,
        'service_name': serviceName,
        'rejection_reason': rejectionReason,
        'created_at': FieldValue.serverTimestamp(),
        'read': false,
        'title': rejectionReason != null ? 'Appointment Rejected' : 'Service Status Update',
        'body': rejectionReason ?? 'Your service status has been updated to: $status'
      });

      // Send push notification if FCM token exists
      if (fcmToken != null) {
        await _notificationService.sendPushNotification(
          fcmToken,
          rejectionReason != null ? 'Appointment Rejected' : 'Service Status Update',
          rejectionReason ?? 'Your service status has been updated to: $status'
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  Future<void> _handleStatusUpdate(DocumentSnapshot doc, String newStatus, String? rejectionReason) async {
    final data = doc.data() as Map<String, dynamic>;
    final userId = data['user_id'];
    final serviceId = data['service_id'];
    final serviceName = data['service_name'] ?? 'Service';

    if (rejectionReason != null) {
      await _sendNotification(userId, serviceId, serviceName, 'rejected', rejectionReason);
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(doc.id)
          .delete();
    } else if (newStatus != data['service_status']) {
      await _sendNotification(userId, serviceId, serviceName, newStatus, null);
    }
  }

  Future<void> _showEditDialog(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    String paymentStatus = data['payment_status'] ?? 'Not Paid';
    String approvalStatus = data['approval_status'] ?? 'pending';
    String serviceStatus = data['service_status'] ?? 'Booked';
    String rejectionReason = data['rejection_reason'] ?? '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Appointment: ${data['name']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdown(
                      'Payment Status',
                      paymentStatus,
                      ['Not Paid', 'Paid'],
                      (value) => setState(() => paymentStatus = value!)
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Approval Status',
                      approvalStatus,
                      ['pending', 'approved', 'rejected'],
                      (value) => setState(() => approvalStatus = value!)
                    ),
                    if (approvalStatus == 'rejected') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: rejectionReason,
                        decoration: const InputDecoration(
                          labelText: 'Rejection Reason',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) => rejectionReason = value,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildDropdown(
                      'Service Status',
                      serviceStatus,
                      ['Booked', 'In Progress', 'Completed'],
                      (value) => setState(() => serviceStatus = value!)
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (approvalStatus == 'rejected') {
                        await _handleStatusUpdate(doc, 'rejected', rejectionReason);
                      } else {
                        await FirebaseFirestore.instance
                            .collection('appointments')
                            .doc(doc.id)
                            .update({
                          'payment_status': paymentStatus,
                          'approval_status': approvalStatus,
                          'service_status': serviceStatus,
                          'updated_at': FieldValue.serverTimestamp(),
                        });

                        if (serviceStatus != data['service_status']) {
                          await _handleStatusUpdate(doc, serviceStatus, null);
                        }
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment updated successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating appointment: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          data['name'] ?? 'Unknown Customer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(formatDate(data['created_at'])),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Service', data['service_name'] ?? 'Unknown Service'),
                _buildInfoRow('Phone', data['phone_number'] ?? 'N/A'),
                _buildInfoRow('Car Type', data['car_type'] ?? 'N/A'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusChip(
                      data['payment_status'] ?? 'Not Paid',
                      _getStatusColor(data['payment_status'] ?? 'Not Paid', 'payment'),
                    ),
                    _buildStatusChip(
                      data['approval_status'] ?? 'pending',
                      _getStatusColor(data['approval_status'] ?? 'pending', 'approval'),
                    ),
                    _buildStatusChip(
                      data['service_status'] ?? 'Booked',
                      _getStatusColor(data['service_status'] ?? 'Booked', 'service'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context, doc),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Appointment'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
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

          if (appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No appointments found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) =>
                _buildAppointmentCard(context, appointments[index]),
          );
        },
      ),
    );
  }
}