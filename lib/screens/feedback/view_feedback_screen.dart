import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

 class ViewFeedbackScreen extends StatelessWidget {
  const ViewFeedbackScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> _getFeedbackStream() {
    return FirebaseFirestore.instance
        .collection('feedback')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) {
      return double.tryParse(rating) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback'),
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFeedbackStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final feedbacks = snapshot.data?.docs ?? [];

          if (feedbacks.isEmpty) {
            return const Center(
              child: Text('No feedback yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final data = feedbacks[index].data() as Map<String, dynamic>;
              final timestamp = data['created_at'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();
              final rating = _parseRating(data['rating']);
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['user_name'] ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Service: ${data['service_name'] ?? 'Unknown Service'}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFFFA000),
                              size: 20,
                            );
                          }),
                          Text(
                            ' ${rating.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Color(0xFFFFA000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['comment'] ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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