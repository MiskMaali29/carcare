import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login with email or username and password
  Future<UserCredential> loginUser({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      // If the input is an email, login directly
      if (emailOrUsername.contains('@')) {
        return await _auth.signInWithEmailAndPassword(
          email: emailOrUsername,
          password: password,
        );
      } else {
        // If it's a username, find the corresponding email in Firestore
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: emailOrUsername)
            .get();

        if (userSnapshot.docs.isEmpty) {
          throw FirebaseAuthException(
              code: 'user-not-found', message: 'No user found with this username.');
        }

        String email = userSnapshot.docs.first.get('email');
        return await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
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
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'fullName': fullName,
        'email': email,
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
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset failed');
    }
  }
}
