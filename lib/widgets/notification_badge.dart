// lib/widgets/notification_badge.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  const NotificationBadge({Key? key, required this.child}) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Stream<int> _getUnreadNotificationsCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }

  void _triggerAnimation() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _getUnreadNotificationsCount(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data! > _lastCount) {
          _triggerAnimation();
        }
        _lastCount = snapshot.data ?? 0;

        if (!snapshot.hasData || snapshot.data == 0) {
          return widget.child;
        }

        return RotationTransition(
          turns: Tween(begin: -0.1, end: 0.1).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.elasticInOut,
            ),
          ),
          child: Stack(
            children: [
              widget.child,
              Positioned(
                right: 0,
                top: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${snapshot.data}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}