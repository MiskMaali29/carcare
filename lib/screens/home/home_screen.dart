import 'package:carcare/screens/home/list.dart';
import 'package:carcare/widgets/bottom_navigation_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_appointment_screen.dart';


class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/test.png',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned(
            top: 90,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quality Automotive Care',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF026DFE),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Professional',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFFF6A20),
                  ),
                ),
                Text(
                  'Service',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFFF6A20),
                  ),
                ),
                Text(
                  'Excellence',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFFF6A20),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              // Custom AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFFFF6A20)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                title: Text(
                  'Hi $username',
                  style: const TextStyle(
                    color: Color(0xFFFF6A20),
                    fontSize: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFFFF6A20)),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/welcome');
                    },
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.only(top: 200),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/robot.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Stay Connected',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Click to our chatbot for instant assistance, service updates, and exclusive offers.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 25),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Chatbot functionality or relevant action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6A20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'Click and ASK!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xFFCCE2FF)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF026DFE),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Do You Want To Make A Booking?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const BookAppointmentScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCCE2FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                               child: const Text(
                                  'Book Appointment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFFE5602),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
     drawer: AppDrawer(username: username),
      bottomNavigationBar: const BottomNavigationIcons(currentIndex: 0),
    );
  }
}

