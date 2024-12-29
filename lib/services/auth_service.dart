
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  // Customer Login
  Future<void> loginUser({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      if (emailOrUsername.contains('@')) {
        // Login using email
        await _auth.signInWithEmailAndPassword(
          email: emailOrUsername.toLowerCase(),
          password: password,
        );
      } else {
        // Login using username
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: emailOrUsername.toLowerCase())
            .get();

        if (userSnapshot.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this username.',
          );
        }

        String email = userSnapshot.docs.first.get('email');
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Register a new user
  Future<UserCredential> registerUser({
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': username.toLowerCase(),
        'fullName': fullName,
        'email': email.toLowerCase(),
        'phone': phone,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset failed');
    }
  }
}
