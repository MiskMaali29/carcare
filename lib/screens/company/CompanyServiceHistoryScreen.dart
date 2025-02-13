import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CompanyHistoryScreen extends StatefulWidget {
  const CompanyHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CompanyHistoryScreen> createState() => _CompanyHistoryScreenState();
}

class _CompanyHistoryScreenState extends State<CompanyHistoryScreen> {
  String selectedFilter = 'today';
  DateTime? selectedDate;
  
  Stream<QuerySnapshot> _getFilteredAppointments() {
 var query = FirebaseFirestore.instance.collection('appointments');

    try {
    if (selectedFilter == 'custom' && selectedDate != null) {
      final startOfDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      return query
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('created_at', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('created_at', descending: true)
          .snapshots();
    }

    switch (selectedFilter) {
      case 'today':
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return query
            .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('created_at', isLessThan: Timestamp.fromDate(endOfDay))
            .orderBy('created_at', descending: true)
            .snapshots();
      
      case 'yesterday':
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return query
            .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('created_at', isLessThan: Timestamp.fromDate(endOfDay))
            .orderBy('created_at', descending: true)
            .snapshots();
      
      case 'week':
        final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return query
            .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
            .orderBy('created_at', descending: true)
            .snapshots();
      
      case 'month':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        return query
            .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
            .orderBy('created_at', descending: true)
            .snapshots();
      
      default:
        return query.orderBy('created_at', descending: true).snapshots();
    }
  } catch (e) {
    print('Error in _getFilteredAppointments: $e');
    return query.orderBy('created_at', descending: true).snapshots();
  }
}
  

  Widget _buildFilterBar() {
    
  //     String getDisplayText() {
  //   if (selectedFilter == 'custom' && selectedDate != null) {
  //     return DateFormat('yyyy-MM-dd').format(selectedDate!);
  //   }
  //   switch (selectedFilter) {
  //     case 'all': return 'All'; 
  //     case 'today': return 'Today';
  //     case 'yesterday': return 'Yesterday';
  //     case 'week': return ' This Week';
  //     case 'month': return 'This Month';
  //     default: return 'All period ';  
  //   }
  // }

  // ignore: unused_element
  String getFilterText() {
    if (selectedFilter == 'custom' && selectedDate != null) {
      return DateFormat('yyyy-MM-dd').format(selectedDate!);
    }
    switch (selectedFilter) {
      case 'today':
        return 'Today';
      case 'yesterday':
        return 'yesterday';
      case 'week':
        return ' week';
      case 'month':
        return 'month ';
      default:
        return 'All ';
    }
  }


    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
                  // Dropdown Menu

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
             child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:   selectedFilter == 'custom' ? 'all' : selectedFilter,
                isExpanded: true,
                items: const [
                  
                   DropdownMenuItem(value: 'all', child: Text('All ')),
                   DropdownMenuItem(value: 'today', child: Text('Today')),
                   DropdownMenuItem(value: 'yesterday', child: Text('Yesterday')),
                   DropdownMenuItem(value: 'week', child: Text('Week ')),
                   DropdownMenuItem(value: 'month', child: Text('Month')),
                  
                ],
             
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedFilter = value;
                    
                        selectedDate = null;
                      
                    });
                  }
                },
              ),
            ),
          ),
        ),
        // Calendar Button

        const SizedBox(width: 12),
        if (selectedDate != null)
                  Expanded(
  child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF026DFE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                DateFormat('yyyy-MM-dd').format(selectedDate!),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF026DFE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.calendar_today, color: Color(0xFF026DFE)),
            onPressed: () => _selectDate(context),
          ),
        ),
      ],
    ),
  );
}
   Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedFilter = 'custom';
      });
    }
  }


// class CompanyHistoryScreen extends StatefulWidget  {
//   const CompanyHistoryScreen({Key? key}) : super(key: key);

//   Stream<QuerySnapshot> _getCompanyAppointments() {
//     return FirebaseFirestore.instance
//         .collection('appointments')
//         .orderBy('created_at', descending: true)
//         .snapshots();
//   }




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
  String note = ''; 
  
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Update Service Details'),
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
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,     
            decoration: const InputDecoration(
              labelText: 'Add Note',
              hintText: 'Enter note for customer',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              note = value;
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
            try {
              // تحديث السعر والملاحظة وحالة الدفع
              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(appointmentId)
                  .update({
                'amount_paid': newPrice,
                'service_note': note,
                'payment_status': 'Paid', // تغيير حالة الدفع تلقائياً
                'note_timestamp': FieldValue.serverTimestamp(),
              });
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service details updated successfully!')),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating service: $e')),
                );
              }
            }
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
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredAppointments(),
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
                    return _buildAppointmentCard(doc);
  },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
                    // final data = doc.data() as Map<String, dynamic>;
                    // final amount = double.tryParse(data['amount_paid']?.toString() ?? '0') ?? 0.0;
                  Widget _buildAppointmentCard(DocumentSnapshot doc) {
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
                                

                                FutureBuilder<String>(
                                future: _getServiceName(data['service_id'] ?? ''),
                                builder: (context, snapshot) {
                                return _buildInfoRow(
                                'Service',
                                snapshot.data ?? 'Loading...',
      );
    },
  ),
                                if (data['approval_status'] == 'rejected')
                                  _buildInfoRow(
                                    'Rejection Reason',
                                    data['rejection_reason'] ?? 'No reason provided',
                                    isError: true
                                  ),

                                   if (data['service_note'] != null && data['service_note'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    'Service Note:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      data['service_note'],
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
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