// lib/models/feedback.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  final String id;
  final String userId;
  final String userName;
  final String serviceId;
  final String serviceName;
  final String comment;
  final double rating;
  final DateTime createdAt;
  final String appointmentId;

  Feedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.serviceId,
    required this.serviceName,
    required this.comment,
    required this.rating,
    required this.createdAt,
    required this.appointmentId,
  });

  factory Feedback.fromFirestore(Map<String, dynamic> data, String id) {
    return Feedback(
      id: id,
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      serviceId: data['service_id'] ?? '',
      serviceName: data['service_name'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      appointmentId: data['appointment_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'service_id': serviceId,
      'service_name': serviceName,
      'comment': comment,
      'rating': rating,
      'created_at': Timestamp.fromDate(createdAt),
      'appointment_id': appointmentId,
    };
  }
}
