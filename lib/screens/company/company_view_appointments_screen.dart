import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class CompanyViewAppointmentsScreen extends StatelessWidget {
  const CompanyViewAppointmentsScreen({Key? key}) : super(key: key);

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
        color: const Color(0xFFBDDBFF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
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

  Future<void> _showEditDialog(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    String paymentStatus = data['payment_status'] ?? 'Not Paid';
    String approvalStatus = data['approval_status'] ?? 'pending';
    String serviceStatus = data['service_status'] ?? 'Booked';
    String rejectionReason = data['rejection_reason'] ?? '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Appointment: ${data['name']}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Payment Status
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: paymentStatus,
                            items: ['Not Paid', 'Paid'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => paymentStatus = newValue);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Approval Status
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Approval Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: approvalStatus,
                            items: ['pending', 'approved', 'rejected'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => approvalStatus = newValue);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Rejection Reason
                    if (approvalStatus == 'rejected')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          initialValue: rejectionReason,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Rejection Reason',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            rejectionReason = value;
                          },
                        ),
                      ),

                    // Service Status
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Service Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: serviceStatus,
                            items: ['Booked', 'In Progress', 'Completed'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => serviceStatus = newValue);
                              }
                            },
                          ),
                        ],
                      ),
                      
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                   final data = doc.data() as Map<String, dynamic>;
                   final userId = data['user_id'];

                  await FirebaseFirestore.instance
                      .collection('appointments')
                      .doc(doc.id)
                      .update({
                    'payment_status': paymentStatus,
                    'approval_status': approvalStatus,
                    'service_status': serviceStatus,
                    'rejection_reason': approvalStatus == 'rejected' ? rejectionReason : null,
                    'updated_at': FieldValue.serverTimestamp(),
                  }); 

// When company rejects an appointment
 if (approvalStatus == 'rejected') {
await FirebaseFirestore.instance.collection('notifications').add({
  'user_id': userId,
  'service_id': data['service_id'],
  'status': 'rejected',
  'rejection_reason': rejectionReason,
  'created_at': FieldValue.serverTimestamp(),
  'read': false,
  'type': 'rejection'
});
  }


// When company updates status

if (serviceStatus != data['service_status']) {
await FirebaseFirestore.instance.collection('notifications').add({
  'user_id': userId,
  'service_id': data['service_id'],
  'type': 'status_update',
  'service_status': serviceStatus,  // 'In Progress', 'Completed', etc.
  'created_at': FieldValue.serverTimestamp(),
  'read': false
});
  }

// If service status changed, create status update notification
      if (serviceStatus != data['service_status']) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'user_id': data['user_id'],  // Note: use data['user_id'] not userId
          'service_id': data['service_id'],
          'type': 'status_update',
          'service_status': serviceStatus,
          'created_at': FieldValue.serverTimestamp(),
          'read': false
        });
      }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment updated successfully!')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update appointment: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF026DFE)),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  formatDate(data['created_at']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusChip(
                    data['payment_status'] ?? 'Not Paid',
                    _getStatusColor(data['payment_status'] ?? 'Not Paid', 'payment'),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    data['approval_status'] ?? 'pending',
                    _getStatusColor(data['approval_status'] ?? 'pending', 'approval'),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    data['service_status'] ?? 'Booked',
                    _getStatusColor(data['service_status'] ?? 'Booked', 'service'),
                  ),
                 
                ],
              ),
              if (data['approval_status'] == 'rejected')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Rejection Reason: ${data['rejection_reason'] ?? 'No reason provided'}',
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditDialog(context, doc),
        ),
      ),
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

          if (appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No appointments found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) =>
                _buildAppointmentCard(context, appointments[index]),
          );
        },
      ),
    );
  }
}
