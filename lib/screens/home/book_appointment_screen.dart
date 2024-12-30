// lib/screens/home/book_appointment_screen.dart

import 'package:carcare/screens/services/appointment_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _auth = FirebaseAuth.instance;
  
  DateTime selectedDate = DateTime.now();
  String? selectedVehicleType;
  String? selectedServiceId;
  String? selectedTimeSlot;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _chassisNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an appointment time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final appointmentData = {
        'name': _nameController.text.trim(),
        'card_number': _cardNumberController.text.trim(),
        'chassis_number': _chassisNumberController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
        'car_type': selectedVehicleType,
        'service_id': selectedServiceId,
        'appointment_date': Timestamp.fromDate(selectedDate),
        'appointment_time': selectedTimeSlot,
        'service_status': 'Booked',
        'payment_status': 'Not Paid',
        'user_id': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _appointmentService.addAppointment(appointmentData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
        
        // Navigate to appointments view
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewAppointmentsScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book appointment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number Field
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Card Number Field
                TextFormField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
   StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('services').snapshots(),
  builder: (context, snapshot) {
    // Handle errors in the stream
    if (snapshot.hasError) {
      return const Center(child: Text('Failed to load services.'));
    }

    // Show a loading indicator while fetching data
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if the collection is empty
    final services = snapshot.data?.docs ?? [];
    if (services.isEmpty) {
      return const Center(child: Text('No services available.'));
    }

    // Map Firestore data to dropdown items
    return DropdownButtonFormField<String>(
      value: selectedServiceId,
      decoration: const InputDecoration(
        labelText: 'Service Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.build),
      ),
      items: services.map((service) {
        final data = service.data() as Map<String, dynamic>;
        return DropdownMenuItem(
          value: service.id, // Use document ID as the value
          child: Text(data['name'] ?? 'Unknown Service'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedServiceId = value);
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

                // Chassis Number Field
                TextFormField(
                  controller: _chassisNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Chassis Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your chassis number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Vehicle Type Dropdown
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  items: ['Hybrid/Electric', 'Sedan', 'SUV', 'Truck']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedVehicleType = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a vehicle type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Service Type Dropdown
           // Date Selection Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    'Select Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (pickedDate != null) {
                      setState(() => selectedDate = pickedDate);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Time Selection Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    selectedTimeSlot == null
                        ? 'Select Appointment Time'
                        : 'Time: $selectedTimeSlot',
                  ),
                  onPressed: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      setState(() => selectedTimeSlot = pickedTime.format(context));
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF026DFE),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Book Appointment',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                // View Appointments Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAppointmentsScreen(),
                      ),
                    );
                  },
                  child: const Text('View My Appointments'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}