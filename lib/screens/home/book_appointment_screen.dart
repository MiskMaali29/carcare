import 'package:flutter/material.dart';
import '../../services/appointment_service.dart'; // تأكد من استيراد الخدمة


class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _appointmentService = AppointmentService();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // الحقول الافتراضية للقوائم المنسدلة
  String _selectedPaymentStatus = 'Not Paid';
  String _selectedServiceStatus = 'Booked';

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      final appointmentDate = "${selectedDate.toLocal()}".split(' ')[0];
      final appointmentTime = selectedTime.format(context);

      // إنشاء بيانات الحجز
      final appointmentData = {
        'name': _nameController.text,
        'card_number': _cardNumberController.text,
        'phone_number': _phoneNumberController.text,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'payment_status': _selectedPaymentStatus, // القيمة المختارة من القائمة
        'service_status': _selectedServiceStatus, // القيمة المختارة من القائمة
      };

      try {
        await _appointmentService.addAppointment(appointmentData); // حفظ البيانات في Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment booked successfully!')),
        );
        Navigator.pop(context); // العودة إلى الشاشة السابقة
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book appointment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  } else if (value.length != 16) {
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPaymentStatus,
                decoration: const InputDecoration(labelText: 'Payment Status'),
                items: [
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'Not Paid', child: Text('Not Paid')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedServiceStatus,
                decoration: const InputDecoration(labelText: 'Service Status'),
                items: [
                  DropdownMenuItem(value: 'Booked', child: Text('Booked')),
                  DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedServiceStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: const Text('Select Appointment Date'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null && pickedTime != selectedTime) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
                child: const Text('Select Appointment Time'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
