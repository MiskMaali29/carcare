import 'package:carcare/screens/home/CustomerServiceHistoryScreen.dart';
import 'package:carcare/screens/home/book_appointment_screen.dart';
import 'package:carcare/screens/home/home_screen.dart';
import 'package:carcare/screens/services/services_screen.dart';
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
          builder: (context) =>  const BookAppointmentScreen(),
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
      MaterialPageRoute
      (builder: (context) => const ServicesScreen()
    ),
     );

      break;
  }
}

  @override
  Widget build(BuildContext context) {
    
    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          //icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, size: 30),
          //icon: Icon(Icons.calendar_today),
          label: 'My Appointments',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.history, size: 34),
         // icon: Icon(Icons.history),
          label: 'My History',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/car_services.png', width: 32, height: 32),
          label: 'services',
        ),
      ],
      currentIndex: widget.currentIndex,
     selectedItemColor: const Color(0xFF026DFE), // Color for the selected item
     unselectedItemColor: const Color(0xFF1F79F4), // Color for unselected items
     backgroundColor: const Color.fromARGB(255, 2, 19, 41), // Background color of the BottomNavigationBar
    onTap: _onItemTapped,
    );
  }
}
