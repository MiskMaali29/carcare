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
  final String amountPaid;
  final String serviceStatus;
  final String serviceName;
  final String approvalStatus;
  final String? rejectionReason; // يمكن أن يكون null إذا لم يتم رفض الحجز
  final String userId;
  final String? serviceNote; // إضافة حقل الملاحظات


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
    required this.amountPaid,
    required this.serviceStatus,
    required this.serviceName,
    required this.approvalStatus,
    this.rejectionReason,
    required this.userId,
    this.serviceNote,
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
      amountPaid: data['amount_paid'] ?? '',
      serviceStatus: data['service_status'] ?? 'Booked',
      serviceName: data['service_name'] ?? '',
      approvalStatus: data['approval_status'] ?? 'pending',
      rejectionReason: data['rejection_reason'], //   
      userId: data['user_id'] ?? '',
      serviceNote: data['service_note'], //   
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
      'approval_status': approvalStatus,
      'service_name': serviceName,
      'amount_paid': amountPaid,
      'rejection_reason': rejectionReason,
      'user_id': userId,
      'service_note': serviceNote,
    };
  }
}
