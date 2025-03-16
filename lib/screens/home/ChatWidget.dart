import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            // Navigate to the chatbot screen or show chat popup
          },
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),
    );
  }
}
