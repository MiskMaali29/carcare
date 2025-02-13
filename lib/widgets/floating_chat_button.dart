// lib/widgets/floating_chat_button.dart

import 'package:flutter/material.dart';
import 'chatbase_widget.dart';

class FloatingChatButton extends StatefulWidget {  // Changed to StatefulWidget
  const FloatingChatButton({Key? key}) : super(key: key);

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),  // One full animation cycle takes 2 seconds
      vsync: this,
    )..repeat(reverse: true);  // Make it go back and forth continuously

    // Create a Tween animation from -5 to 5
    _animation = Tween<double>(
      begin: -5.0,  // Move up 5 pixels
      end: 5.0,     // Move down 5 pixels
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,  // Smooth animation curve
    ));
  }

  @override
  void dispose() {
    _controller.dispose();  // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          right: 16,
          bottom: 30 + _animation.value,  // Add animation value to base position
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(48),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(64),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCCE2FF), Color(0xFFCCE2FF)],
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(48),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Center(
                    child: Image.asset(
                      'assets/images/chat_bot.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Keep your ChatScreen class as is
class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MotorCarCare Chatbot'),
        backgroundColor: const Color(0xFF026DFE),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SafeArea(
        child: ChatWidget(),
      ),
    );
  }
}