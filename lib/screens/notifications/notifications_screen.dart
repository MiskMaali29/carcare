// lib/screens/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> _getNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Date not available';
    return DateFormat('MMM d, yyyy - h:mm a').format(timestamp.toDate());
  }

  Widget _buildNotificationContent(Map<String, dynamic> notification) {
    final status = notification['status'];
    final rejectionReason = notification['rejection_reason'];
    final serviceName = notification['service_name'] ?? 'Service';
    final created_at = notification['created_at'] as Timestamp?;

    if (status == 'rejected') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cancel, color: Colors.red[400], size: 16),
              const SizedBox(width: 4),
              Text(
                'Appointment Rejected',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Service: $serviceName',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          if (rejectionReason != null) ...[
            const SizedBox(height: 4),
            Text(
              'Reason: $rejectionReason',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            _formatDate(created_at),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    // For status updates
    if (notification['type'] == 'status_update') {
      final newStatus = notification['service_status'] ?? 'Updated';
      Color statusColor;
      switch (newStatus.toLowerCase()) {
        case 'in progress':
          statusColor = Colors.blue;
          break;
        case 'completed':
          statusColor = Colors.green;
          break;
        default:
          statusColor = Colors.orange;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Status Updated',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  newStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(created_at),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    // Default notification layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification['title'] ?? 'New Notification',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (notification['body'] != null) ...[
          const SizedBox(height: 4),
          Text(
            notification['body'],
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          _formatDate(created_at),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final notificationId = notifications[index].id;
              final isRead = notification['read'] ?? false;

              return Dismissible(
                key: Key(notificationId),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notificationId)
                      .delete();
                },
                child: Card(
                  elevation: isRead ? 1 : 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isRead ? Colors.white : const Color(0xFFE3F2FD),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF026DFE).withOpacity(0.1),
                      child: const Icon(
                        Icons.notification_important,
                        color: Color(0xFF026DFE),
                      ),
                    ),
                    title: _buildNotificationContent(notification),
                    onTap: () => _markAsRead(notificationId),
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