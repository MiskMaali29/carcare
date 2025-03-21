import 'package:carcare/screens/home/CustomerServiceHistoryScreen.dart';
import 'package:carcare/screens/home/book_appointment_screen.dart';
import 'package:carcare/screens/home/home_screen.dart';
import 'package:carcare/screens/home/setting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomNavigationIcons extends StatefulWidget {
  
  final int currentIndex;

  const BottomNavigationIcons({super.key, required this.currentIndex});

  @override
  _BottomNavigationIconsState createState() => _BottomNavigationIconsState();
}

class _BottomNavigationIconsState extends State<BottomNavigationIcons> {
  
  void _onItemTapped(int index) {
  switch (index) {
    case 0: // Home Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(username: 'User'),
        ),
      );
      break;

    case 1: // Book Appointment Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BookAppointmentScreen(),
        ),
      );
      break;

    case 2: // Customer Service History Screen
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your service history.')),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerServiceHistoryScreen(userId: user.uid),
        ),
      );
      break;

    case 3: // Settings Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AboutUsScreen(),
        ),
      );
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          //icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, size: 30),
          //icon: Icon(Icons.calendar_today),
          label: 'My Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history, size: 34),
         // icon: Icon(Icons.history),
          label: 'My History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: 30),
          //icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: widget.currentIndex,
    selectedItemColor: const Color(0xFFFF6A20), // Color for the selected item
    unselectedItemColor: const Color.fromARGB(255, 255, 141, 84), // Color for unselected items
    backgroundColor: const Color.fromARGB(255, 2, 19, 41), // Background color of the BottomNavigationBar
    onTap: _onItemTapped,
    );
  }
}
