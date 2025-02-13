import 'package:carcare/models/service.dart';

import 'package:carcare/screens/services/appointment_service.dart';
import 'package:carcare/screens/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../widgets/notification_overlay.dart';
import 'view_appointments_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
final String? initialServiceId;

const BookAppointmentScreen({
    Key? key, 
    this.initialServiceId  
  }) : super(key: key);


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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  String? selectedVehicleType;
  String? selectedServiceId;
  bool _isLoading = false;

   @override
  void initState() {
    super.initState();
      _loadUserData();

    if (widget.initialServiceId != null) {
      setState(() {
        selectedServiceId = widget.initialServiceId;
      });
    }
  }

  Future<void> _loadUserData() async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (userData.exists) {
        setState(() {
          _nameController.text = userData.get('fullName') ?? '';
          _phoneNumberController.text = userData.get('phone') ?? '';
        });
      }
    }
  } catch (e) {
    print('Error loading user data: $e');
  }
}

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _chassisNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate() || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select time.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');
      if (selectedServiceId == null) throw Exception('Please select a service');

      final serviceSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .doc(selectedServiceId)
          .get();

      if (!serviceSnapshot.exists) throw Exception('Selected service not found');

      final service = Service.fromFirestore(serviceSnapshot.data()!, serviceSnapshot.id);


 final DateTime appointmentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

      final appointmentData = {
        'name': _nameController.text.trim(),
        'card_number': _cardNumberController.text.trim(),
        'chassis_number': _chassisNumberController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
        'car_type': selectedVehicleType,
        'service_id': service.id,
        'service_name': service.name,
        'service_price': service.price,
        'amount_paid': service.price,
        'appointment_date': Timestamp.fromDate(appointmentDateTime),
        'appointment_time': '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
        'service_status': 'Booked',
        'payment_status': 'Not Paid',
        'user_id': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _appointmentService.addAppointment(appointmentData);
            final notificationService = NotificationService();
      await notificationService.scheduleAppointmentReminder(
        appointmentDateTime,
        'Upcoming Appointment',
        'You have a ${service.name} appointment tomorrow at ${selectedTime!.format(context)}'
      );
      

  if (mounted) {
        NotificationOverlay.show(
          context,
          'Appointment Booked',
          'Your appointment for ${service.name} has been scheduled successfully!',
        );
      }
      
      //if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewAppointmentsScreen()),
        );
      
     } catch (e) {
    print('Error booking appointment: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Select Time (8:00 AM - 5:00 PM)',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && picked.hour >= 8 && picked.hour <= 17) {
      setState(() {
        selectedTime = picked;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time between 8:00 AM and 5:00 PM')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  

Widget buildBottomSection() {
 return Column(
   children: [
     Row(
       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
       children: [
         Container(
           decoration: BoxDecoration(
             color: const Color.fromARGB(255, 114, 173, 255),
             borderRadius: BorderRadius.circular(12),
           ),
           child: Material(
             color: Colors.transparent,
             child: InkWell(
               onTap: () => _selectDate(context),
               borderRadius: BorderRadius.circular(12),
               child: Padding(
                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Icon(Icons.calendar_today, size: 30, color: Color(0xFF026DFE)),
                     const SizedBox(height: 8),
                    // const Text('Choose Date', style: TextStyle(fontSize: 16, color: Colors.black)),
                     const SizedBox(height: 4),
                     Text(
                       DateFormat('MMM dd, yyyy').format(selectedDate),
                       style: const TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFF026DFE)
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ),
         Container(
           decoration: BoxDecoration(
             color: const Color.fromARGB(255, 114, 173, 255),
             borderRadius: BorderRadius.circular(12),
           ),
           child: Material(
             color: Colors.transparent,
             child: InkWell(
               onTap: () => _selectTime(context),
               borderRadius: BorderRadius.circular(12),
               child: Padding(
                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Icon(Icons.access_time, size: 30, color: Color(0xFF026DFE)),
                     const SizedBox(height: 8),
                   //  const Text('Choose Time', style: TextStyle(fontSize: 16, color: Colors.black)),
                     const SizedBox(height: 4),
                     Text(
                       selectedTime?.format(context) ?? 'Not Selected',
                       style: const TextStyle(
                         fontSize: 14,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFF026DFE)
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ),
       ],
     ),
     const SizedBox(height: 20),
     ElevatedButton(
       onPressed: _isLoading ? null : _bookAppointment,
       style: ElevatedButton.styleFrom(
         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 110),
         backgroundColor: const Color(0xFF026DFE),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       ),
       child: _isLoading
         ? const CircularProgressIndicator(color: Colors.white)
         : const Text('Book Appointment', style: TextStyle(fontSize: 16, color: Colors.white)),
     ),
   ],
 );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color.fromARGB(255, 114, 173, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
         actions: [
        IconButton(
          icon: const Icon(Icons.event_note, size: 26), 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewAppointmentsScreen()),
            );
          },
        ),
      ],
    ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 114, 173, 255), Color.fromARGB(255, 246, 246, 248)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                 // buildViewAppointmentsButton(),
                
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, 'Name', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneNumberController, 'Phone Number', Icons.phone, TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(_cardNumberController, 'Card Number', Icons.credit_card, TextInputType.number),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('services').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Text('Error loading services');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final services = snapshot.data?.docs ?? [];
                      return DropdownButtonFormField<String>(
                        value: selectedServiceId,
                        decoration: InputDecoration(
                          labelText: 'Service Type',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.build),
                        ),
                        items: services.map((service) {
                          final data = service.data() as Map<String, dynamic>;
                          return DropdownMenuItem(value: service.id, child: Text(data['name'] ?? 'Unnamed Service'));
                        }).toList(),
                        onChanged: (value) => setState(() => selectedServiceId = value),
                        validator: (value) => value == null || value.isEmpty ? 'Please select a service' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_chassisNumberController, 'Chassis Number', Icons.numbers),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedVehicleType,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.directions_car),
                    ),
                    items: ['Hybrid/Electric', 'Sedan', 'SUV', 'Truck']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedVehicleType = value),
                    validator: (value) => value == null || value.isEmpty ? 'Please select a vehicle type' : null,
                  ),
                  const SizedBox(height: 16),
                  buildBottomSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }
}
