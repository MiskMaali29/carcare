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
        'approval_status': 'pending', // Default approval status
        'rejection_reason': null, // Default rejection reason
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

      await _appointmentCollection.doc(id).update(updatedData);
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Create a new appointment with enhanced data
  Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      // Fetch service details from the services collection
      final serviceDoc = await FirebaseFirestore.instance
          .collection('services')
          .doc(appointmentData['service_id'])
          .get();

      if (!serviceDoc.exists) {
        throw Exception('Service not found');
      }

      final serviceData = serviceDoc.data()!;

      // Add additional details to appointment data
      final enhancedAppointmentData = {
        ...appointmentData,
        'approval_status': 'pending',
        'rejection_reason': null,
        'estimated_duration': serviceData['duration'] ?? 30, // Default duration
        'service_name': serviceData['name'], // Service name from services
        'created_at': FieldValue.serverTimestamp(),
        'service_status': 'Booked',
        'payment_status': 'Not Paid'
      };

      await _appointmentCollection.add(enhancedAppointmentData);
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
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
