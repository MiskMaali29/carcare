import 'package:carcare/screens/home/CustomerServiceHistoryScreen.dart';
import 'package:carcare/screens/home/about_us.dart';
import 'profile.dart';  // Add this import at the top of list.dart
import 'package:carcare/screens/home/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_appointment_screen.dart';
import 'welcome_screen.dart';

class AppDrawer extends StatefulWidget {
  final String username;

  const AppDrawer({Key? key, required this.username}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Fixed DrawerHeader
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // Important change
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,  // Reduced size
                      backgroundImage: AssetImage('assets/images/logo192.png'),
                      backgroundColor: AppColors.background,
                    ),
                    const SizedBox(height: 8),  // Reduced spacing
                    Text(
                      'Hello, ${widget.username}',
                      style: const TextStyle(
                        color: AppColors.babyblue,
                        fontSize: 20,  // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Menu Items in Expanded widget
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.calendar_today,
                    title: 'Book Appointment',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Service History',
                    onTap: () {
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
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(username: widget.username),
                      ),
                    ),
                  ),
                   _buildMenuItem(
                    icon: Icons.person,
                    title: 'About Us',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutUsScreen(username: widget.username),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),

            // Logout Option at bottom
            _buildMenuItem(
  icon: Icons.logout,
  title: 'Logout',
  color: AppColors.error,
  onTap: () async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()), // Or your login screen
        (route) => false, // This removes all previous routes
      );
    }
  },
),
          ],
        ),
      ),
    );
  }

  // Helper method for menu items
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.secondary,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color == AppColors.secondary ? AppColors.textPrimary : color,
          fontSize: 20,
        ),
      ),
      onTap: onTap,
      dense: true,  // Makes the ListTile more compact
    );
  }
}

// Colors class remains the same
class AppColors {
  static const Color primary = Color(0xFF026DFE);
  static const Color secondary = Color(0xFFFE5602);
  static const Color background = Color(0xFFBDDBFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color babyblue = Color(0xFFCCE2FF);
  static const Color babyorange = Color(0xFFFF6A20);
}