// lib/screens/company/manage_services_screen.dart

import 'package:carcare/screens/services/service_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/service.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({Key? key}) : super(key: key);

  @override
  _ManageServicesScreenState createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final ServiceService _serviceService = ServiceService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Service'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter service name' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter description' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter price' : null,
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    hintText: 'Enter estimated service duration',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter duration' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addService,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addService() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('No authenticated user found');
        }

        final service = Service(
          id: '', // Firestore will generate this
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          duration: int.parse(_durationController.text),
          companyId: currentUser.uid,
        );

        await _serviceService.addService(service);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding service: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        backgroundColor: const Color(0xFF026DFE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _serviceService.getCompanyServicesStream(currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: services.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final data = services[index].data() as Map<String, dynamic>;
              final service = Service.fromFirestore(data, services[index].id);

              return Card(
                child: ListTile(
                  title: Text(service.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.description),
                      Text('Price: \$${service.price}'),
                      Text('Duration: ${service.duration} minutes'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Edit service functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _serviceService.deleteService(service.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        backgroundColor: const Color(0xFF026DFE),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}