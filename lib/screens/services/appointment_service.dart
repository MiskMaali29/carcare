// lib/services/appointment_service.dart
import 'package:carcare/models/appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  final CollectionReference _appointmentCollection =
      FirebaseFirestore.instance.collection('appointments');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add an appointment to Firestore
  Future<void> addAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Add necessary fields
      final enhancedData = {
        ...appointmentData,
        'user_id': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'payment_status': 'Not Paid',
        'service_status': 'Booked',
        // Ensure these fields exist with default values if not provided
        'phone_number': appointmentData['phone_number'] ?? '',
        'service_id': appointmentData['service_id'],
        'chassis_number': appointmentData['chassis_number'] ?? '',
        'car_type': appointmentData['car_type'] ?? '',
      };

      await _appointmentCollection.add(enhancedData);
    } catch (e) {
      throw Exception('Failed to add appointment: $e');
    }
  }

  // Fetch appointments for current user
  Future<List<Appointment>> fetchAppointments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final querySnapshot = await _appointmentCollection
          .where('user_id', isEqualTo: user.uid)
          .orderBy('appointment_date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Appointment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  // Get appointments stream for current user
  Stream<QuerySnapshot> getAppointmentsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    return _appointmentCollection
        .where('user_id', isEqualTo: user.uid)
        .orderBy('appointment_date', descending: true)
        .snapshots();
  }

  // Check if a slot is available
  Future<bool> isSlotAvailable(String date, String time) async {
    try {
      final querySnapshot = await _appointmentCollection
          .where('appointment_date', isEqualTo: date)
          .where('appointment_time', isEqualTo: time)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check slot availability: $e');
    }
  }

  // Update an existing appointment
  Future<void> updateAppointment(String id, Map<String, dynamic> updatedData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Verify appointment ownership before update
      final doc = await _appointmentCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Appointment not found');
      }

      final appointmentData = doc.data() as Map<String, dynamic>;
      if (appointmentData['user_id'] != user.uid) {
        throw Exception('Unauthorized to update this appointment');
      }

      await _appointmentCollection.doc(id).update(updatedData);
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Delete an appointment
  Future<void> deleteAppointment(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Verify appointment ownership before deletion
      final doc = await _appointmentCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Appointment not found');
      }

      final appointmentData = doc.data() as Map<String, dynamic>;
      if (appointmentData['user_id'] != user.uid) {
        throw Exception('Unauthorized to delete this appointment');
      }

      await _appointmentCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  // Get single appointment details
  Future<Appointment?> getAppointmentDetails(String id) async {
    try {
      final doc = await _appointmentCollection.doc(id).get();
      if (!doc.exists) {
        return null;
      }
      return Appointment.fromFirestore(doc.data() as Map<String, dynamic>, id);
    } catch (e) {
      throw Exception('Failed to get appointment details: $e');
    }
  }
}