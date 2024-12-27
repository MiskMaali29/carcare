// lib/models/appointment.dart
class Appointment {
  final String id;
  final String name;
  final String cardNumber;
  final String phoneNumber;
  final String carType;
  final String chassisNumber;
  final String appointmentDate;
  final String appointmentTime;
  final String paymentStatus;
  final String serviceStatus;
  final String userId;

  Appointment({
    required this.id,
    required this.name,
    required this.cardNumber,
    required this.phoneNumber,
    required this.carType,
    required this.chassisNumber,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.paymentStatus,
    required this.serviceStatus,
    required this.userId,
  });

  // Convert Firestore document to Appointment object
  factory Appointment.fromFirestore(Map<String, dynamic> data, String id) {
    return Appointment(
      id: id,
      name: data['name'] ?? '',
      cardNumber: data['card_number'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      carType: data['car_type'] ?? '',
      chassisNumber: data['chassis_number'] ?? '',
      appointmentDate: data['appointment_date'] ?? '',
      appointmentTime: data['appointment_time'] ?? '',
      paymentStatus: data['payment_status'] ?? 'Not Paid',
      serviceStatus: data['service_status'] ?? 'Booked',
      userId: data['user_id'] ?? '',
    );
  }

  // Convert Appointment object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'card_number': cardNumber,
      'phone_number': phoneNumber,
      'car_type': carType,
      'chassis_number': chassisNumber,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'payment_status': paymentStatus,
      'service_status': serviceStatus,
      'user_id': userId,
    };
  }
}
