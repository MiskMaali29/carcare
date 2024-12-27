// lib/services/appointment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final CollectionReference _appointmentCollection =
      FirebaseFirestore.instance.collection('appointments');

  // Add an appointment to Firestore
  Future<void> addAppointment(Map<String, dynamic> appointmentData) async {
    try {
      await _appointmentCollection.add(appointmentData);
    } catch (e) {
      throw Exception('Failed to add appointment: $e');
    }
  }

  // Fetch all appointments from Firestore
  Future<List<Appointment>> fetchAppointments() async {
    try {
      final querySnapshot = await _appointmentCollection.get();
      return querySnapshot.docs.map((doc) {
        // Use the fromFirestore method to map Firestore data to Appointment
        return Appointment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }



  // Check if a slot is available
  Future<bool> isSlotAvailable(String date, String time) async {
    final querySnapshot = await _appointmentCollection
        .where('appointment_date', isEqualTo: date)
        .where('appointment_time', isEqualTo: time)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  // Update an existing appointment
  Future<void> updateAppointment(String id, Map<String, dynamic> updatedData) async {
    try {
      await _appointmentCollection.doc(id).update(updatedData);
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Delete an appointment
  Future<void> deleteAppointment(String id) async {
    try {
      await _appointmentCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

}