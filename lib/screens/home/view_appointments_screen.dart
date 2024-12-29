import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewAppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
  itemCount: appointments.length,
  itemBuilder: (context, index) {
    final appointment = appointments[index].data() as Map<String, dynamic>; // احصل على البيانات كمصفوفة

  String formattedDate = 'Unknown';
              String formattedTime = 'Unknown';

              if (appointment['appointment_date'] != null) {
                 if (appointment['appointment_date'] is String) {
                   formattedDate = appointment['appointment_date'];
               } else if (appointment['appointment_date'] is Timestamp) {
    final date = (appointment['appointment_date'] as Timestamp).toDate();
    formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
 // تنسيق التاريخ
  }
}

              if (appointment['appointment_time'] != null) {
                formattedTime = appointment['appointment_time']; // عرض الوقت مباشرة
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(appointment['name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: $formattedDate, Time: $formattedTime'),
                      Text('Vehicle Type: ${appointment['vehicle_type'] ?? 'Unknown'}'),
                    ],
                  ),
                  trailing: Text(
                    'Status: ${appointment.containsKey('service_status') ? appointment['service_status'] : 'Unknown'}',
                    style: TextStyle(
                      color: appointment['service_status'] == 'Completed'
                          ? Colors.green
                          : (appointment['service_status'] == 'In Progress'
                              ? Colors.orange
                              : Colors.red),
                    ),
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
