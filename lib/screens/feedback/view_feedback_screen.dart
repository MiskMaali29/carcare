// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

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

  Widget _buildFeedbackCard(DocumentSnapshot feedback) {
    
    final isCompany = FirebaseAuth.instance.currentUser?.uid == feedback.get('company_id');

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
                  feedback.get('user_name') ?? 'Anonymous',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isCompany)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => FirebaseFirestore.instance
                        .collection('feedback')
                        .doc(feedback.id)
                        .delete(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Service: ${feedback.get('service_name') ?? 'Unknown Service'}',
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
                    index < _parseRating(feedback.get('rating'))
                        ? Icons.star
                        : Icons.star_border,
                    color: const Color(0xFFFFA000),
                    size: 20,
                  );
                }),
                Text(
                  ' ${_parseRating(feedback.get('rating')).toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Color(0xFFFFA000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback.get('comment') ?? '',
              style: const TextStyle(fontSize: 14),
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
        title: const Text('Reviews'),
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final feedbacks = snapshot.data!.docs;
          if (feedbacks.isEmpty) {
            return const Center(child: Text('No reviews yet'));
          }

          return ListView.builder(
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final data = feedbacks[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['user_name'] ?? 'Anonymous'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) => Icon(
                          index < (data['rating'] ?? 0) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        )),
                      ),
                      Text(data['comment'] ?? ''),
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