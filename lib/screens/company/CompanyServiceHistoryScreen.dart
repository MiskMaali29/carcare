import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CompanyHistoryScreen extends StatelessWidget {
  const CompanyHistoryScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> _getCompanyAppointments() {
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
        final DateFormat formatter = DateFormat('MMM d, yyyy - hh:mm a');
        return formatter.format(date);
      }
      return timestamp.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    try {
      // Handle different numeric formats
      double value = 0.0;
      if (amount is String) {
        value = double.tryParse(amount) ?? 0.0;
      } else if (amount is num) {
        value = amount.toDouble();
      }
      return '\$${value.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
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

  Future<String> _getServiceName(String serviceId) async {
    try {
      final serviceDoc = await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .get();
      return serviceDoc.data()?['name'] ?? 'Unknown Service';
    } catch (e) {
      return 'Unknown Service';
    }
  }

  Future<void> _updateServicePrice(BuildContext context, String appointmentId, double currentPrice) async {
    double newPrice = currentPrice;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Service Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Price',
                prefixText: '\$',
              ),
              onChanged: (value) {
                newPrice = double.tryParse(value) ?? currentPrice;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(appointmentId)
                  .update({'amount_paid': newPrice});
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
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
        stream: _getCompanyAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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

          // Calculate statistics
          int totalAppointments = appointments.length;
          int completedServices = appointments
              .where((doc) => (doc.data() as Map<String, dynamic>)['service_status'] == 'Completed')
              .length;
          double totalRevenue = appointments
              .map((doc) {
                final amount = (doc.data() as Map<String, dynamic>)['amount_paid'];
                if (amount == null) return 0.0;
                return double.tryParse(amount.toString()) ?? 0.0;
              })
              .fold(0.0, (prev, amount) => prev + amount);

          return Column(
            children: [
              // Statistics Cards
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Services',
                        totalAppointments.toString(),
                        Icons.build,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        completedServices.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatCard(
                        'Revenue',
                        formatCurrency(totalRevenue),
                        Icons.attach_money,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // History List
              Expanded(
                child: ListView.builder(
                  itemCount: appointments.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final doc = appointments[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = double.tryParse(data['amount_paid']?.toString() ?? '0') ?? 0.0;
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _getStatusColor(data['service_status'] ?? '').withOpacity(0.1),
                              child: Text(
                                (data['name'] ?? 'U')[0].toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(data['service_status'] ?? ''),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? 'Unknown Customer',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  FutureBuilder<String>(
                                    future: _getServiceName(data['service_id'] ?? ''),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? 'Loading service...',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateServicePrice(context, doc.id, amount),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Date', formatDate(data['created_at'])),
                                _buildInfoRow('Status', data['service_status'] ?? 'N/A'),
                                _buildInfoRow('Payment', data['payment_status'] ?? 'Not Paid'),
                                _buildInfoRow('Amount', formatCurrency(amount)),
                                _buildInfoRow('Phone', data['phone_number'] ?? 'N/A'),
                                _buildInfoRow('Car Type', data['car_type'] ?? 'N/A'),
                                _buildInfoRow('Card Number', data['card_number'] ?? 'N/A'),
                                
                                if (data['approval_status'] == 'rejected')
                                  _buildInfoRow(
                                    'Rejection Reason',
                                    data['rejection_reason'] ?? 'No reason provided',
                                    isError: true
                                  ),

                                const SizedBox(height: 12),
                                
                                // Service Status Indicator
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(data['service_status'] ?? '').withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: _getStatusColor(data['service_status'] ?? ''),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Service ${data['service_status'] ?? 'Unknown'}',
                                        style: TextStyle(
                                          color: _getStatusColor(data['service_status'] ?? ''),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
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