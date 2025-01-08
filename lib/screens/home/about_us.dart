import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key, required String username});

@override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Fade animation for text
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Slide animation for the logo
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBDDBFF),
      appBar: AppBar(
        backgroundColor: Color(0xFF026DFE),
        elevation: 0,
        title: const Text(
          "About Us",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated Logo
            SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFFFE5602), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/car_image.png',
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Animated Welcome Text
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: Text(
                  'Welcome to MotorCarCare',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mission Statement
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF026DFE).withOpacity(0.1), // Slightly lighter background color
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF6A20),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'At MotorCarCare,we aim to revolutionize the car repair experience by providing a seamless\n'
                      'efficient,and user-friendly platform for car owners and workshop managers alike.',
                      style: TextStyle(
                        fontFamily: 'Sen',
                        fontSize: 16,
                        color:  Color(0xFF212121),
                        height: 1.5,
                        fontWeight: FontWeight.w300, 
                      ),
                     textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Core Values
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color:Color(0xFF026DFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Our Core Values',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF6A20),
                      ),
                    ),
                  RichText(
  textAlign: TextAlign.start,
  text: const TextSpan(
    style: TextStyle(
      fontSize: 14,
      
      color: Color(0xFF212121),
      fontFamily: 'Sen',
      fontWeight: FontWeight.w300,

      height: 1.5,
    ),
    children: [
      // TextSpan(
      //   text: 'At Motor CarCare, we stand by our core values:\n',
      //   style: TextStyle(
      //     fontSize: 18,
      //     fontFamily: 'Sen',
      //     fontWeight: FontWeight.w500,
      //     color: Color(0xFF026DFE),  // اللون الأزرق الرئيسي للتطبيق
      //   ),
      // ),
      TextSpan(
        text: 'Excellence',
        style: TextStyle(
          fontSize: 16,
          fontFamily:'Sen',
          fontWeight: FontWeight.w300,
          color: Color(0xFF026DFE),
        ),
      ),
      TextSpan(
        text: ': Delivering superior service without compromise\n',
      ),
      TextSpan(
        text: 'Trust',
        style: TextStyle(
          fontSize: 16,
          fontFamily:'Sen', 
          fontWeight: FontWeight.w500,
          color: Color(0xFF026DFE),
        ),
      ),
      TextSpan(
        text: ': Building lasting relationships through transparency\n',
      ),
      TextSpan(
        text: 'Innovation',
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Sen',
          fontWeight: FontWeight.w500,
          color: Color(0xFF026DFE),
        ),
      ),
      TextSpan(
        text: ': Embracing modern solutions for better care\n',
      ),
      TextSpan(
        text: 'Customer Focus',
        style: TextStyle(
          fontSize: 16,
          fontFamily:'Sen',
          fontWeight: FontWeight.w500,
          color: Color(0xFF026DFE),
        ),
      ),
      TextSpan(
        text: ': Making your satisfaction our priority\n',
      ),
      TextSpan(
        text: 'Efficiency',
        style: TextStyle(
          fontSize: 16,
          fontFamily:'Sen', 
          fontWeight: FontWeight.w500,
          color: Color(0xFF026DFE),
        ),
      ),
      TextSpan(
        text: ': Respecting your time while ensuring quality',
      ),
    ],
  ),
)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


