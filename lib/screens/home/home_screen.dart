import 'package:carcare/screens/feedback/view_feedback_screen.dart';
import 'package:carcare/screens/home/list.dart';
import 'package:carcare/screens/notifications/notifications_screen.dart';
import 'package:carcare/screens/services/service_details.dart';
import 'package:carcare/utils/service_icons.dart';
import 'package:carcare/widgets/bottom_navigation_icons.dart';
import 'package:carcare/widgets/floating_chat_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/notification_badge.dart';
import '../../models/service.dart';
import 'book_appointment_screen.dart';
import '../services/services_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _allServices = [];
  List<QueryDocumentSnapshot> _filteredServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('services').get();
      setState(() {
        _allServices = snapshot.docs;
        _filteredServices = _allServices;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading services: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      if (searchQuery.isEmpty) {
        _filteredServices = _allServices;
      } else {
        _filteredServices = _allServices.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final description = (data['description'] ?? '').toString().toLowerCase();
          return name.contains(searchQuery) || description.contains(searchQuery);
        }).toList();
      }
    });
  }

  Widget _buildServiceIcon(String serviceName) {
      return ServiceIcons.getServiceIcon(serviceName);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF026DFE),
      body: Stack(
      //  child: Column(
          children: [
             SafeArea(
              child: Column(
            children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Builder(
                          builder: (BuildContext context) {
                            return IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            );
                          },
                        ),
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Color(0xFF026DFE)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Hi, ${widget.username.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  NotificationBadge(
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search for services...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Main Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Popular Services',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ServicesScreen()),
                              ),
                              child: const Text('See more'),
                            ),
                          ],
                        ),
                      ),

                      // Services List
                      SizedBox(
                        height: 120,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _searchController.text.isEmpty
                                    ? _allServices.length
                                    : _filteredServices.length,
                                itemBuilder: (context, index) {
                                  final service = Service.fromFirestore(
                                    (_searchController.text.isEmpty
                                            ? _allServices
                                            : _filteredServices)[index]
                                        .data() as Map<String, dynamic>,
                                    (_searchController.text.isEmpty
                                            ? _allServices
                                            : _filteredServices)[index]
                                        .id,
                                  );
                                  return Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: GestureDetector(
                                     onTap: () {
                                    showModalBottomSheet(
                                     context: context,
                                     isScrollControlled: true,
                                     backgroundColor: Colors.transparent,
                                     builder: (context) => ServiceDetails(service: service),
                                      );
                                     },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF026DFE)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                      
                                      
                                      
                                      
                                           BorderRadius.circular(15),
                                            ),
                                            child: _buildServiceIcon(service.name),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            service.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Booking Card
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Book Appointment',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const BookAppointmentScreen(),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF026DFE),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('Book Now'),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                'assets/images/car_image.png',
                                width: 80,
                                height: 80,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Reviews and Emergency Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Reviews Card
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ViewFeedbackScreen()),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.star,
                                          color: Color(0xFFFFD700)),
                                      SizedBox(height: 8),
                                      Text(
                                        'Customer Reviews',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '4.8/5',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Emergency Card
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  const String phoneNumber = '+972597395515';
                                  try {
                                    final Uri phoneUri =
                                        Uri.parse('tel:$phoneNumber');
                                    if (await canLaunchUrl(phoneUri)) {
                                      await launchUrl(phoneUri,
                                          mode:
                                              LaunchMode.externalApplication);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Error: ${e.toString()}')),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3F3),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.emergency, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text(
                                        'Emergency',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Get immediate help',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        const FloatingChatButton(),

    ],
    ),
      drawer: AppDrawer(username: widget.username),
      bottomNavigationBar: const BottomNavigationIcons(currentIndex: 0),
    );
  }
}