import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/appointment_service.dart';
import 'view_appointments_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _appointmentService = AppointmentService();
  DateTime selectedDate = DateTime.now();
  String? selectedVehicleType;
  String? selectedServiceId;
  String? _selectedServiceStatus = 'Booked'; // الحالة الافتراضية
  String? selectedTimeSlot;

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      final appointmentData = {
        'name': _nameController.text,
        'card_number': _cardNumberController.text,
        'chassis_number': _chassisNumberController.text,
        'phone_number': _phoneNumberController.text,
        'vehicle_type': selectedVehicleType,
        'service_id': selectedServiceId,
        'appointment_date': selectedDate,
        'appointment_time': selectedTimeSlot,
        'service_status': _selectedServiceStatus, // الحالة المحددة
      };

      try {
        await _appointmentService.addAppointment(appointmentData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment booked successfully!')),
        );
        Navigator.pop(context);
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
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chassisNumberController,
                decoration: const InputDecoration(labelText: 'Chassis Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your chassis number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedVehicleType,
                decoration: const InputDecoration(labelText: 'Vehicle Type'),
                items: ['Hybrid/Electric', 'Sedan', 'SUV', 'Truck']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVehicleType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a vehicle type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('services').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final services = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: selectedServiceId,
                    decoration: const InputDecoration(labelText: 'Service Type'),
                    items: services.map((service) {
                      return DropdownMenuItem(
                        value: service.id,
                        child: Text(service['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedServiceId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a service type';
                      }
                      return null;
                    },
                  );
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
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  'Select Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      selectedTimeSlot = pickedTime.format(context);
                    });
                  }
                },
                child: Text(selectedTimeSlot == null
                    ? 'Select Appointment Time'
                    : 'Time: $selectedTimeSlot'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _bookAppointment,
                child: const Text('Book Appointment'),
              ),
              ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewAppointmentsScreen()),
    );
  },
  child: const Text('View Appointments'),
),

            ],
          ),
        ),
      ),
    );
  }
}
