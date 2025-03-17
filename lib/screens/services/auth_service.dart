import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<String> loginUser({
  required String emailOrUsername,
  required String password,
}) async {
  try {
    String? email;
    String username;
    final inputValue = emailOrUsername.toLowerCase().trim();
    
    if (!inputValue.contains('@')) {
      final QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: inputValue)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this username',
        );
      }
      
      email = userSnapshot.docs.first.get('email') as String;
      username = inputValue;
    } else {
      email = inputValue;
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (userSnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this email',
        );
      }
      
      username = userSnapshot.docs.first.get('username') as String;
    }

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }

    return username;
    
  } on FirebaseAuthException catch (e) {
    String message = switch (e.code) {
      'user-not-found' => 'No account found with these credentials',
      'wrong-password' => 'Invalid password',
      'invalid-email' => 'Invalid email format',
      'user-disabled' => 'This account has been disabled',
      _ => 'Login error: ${e.message}',
    };
    throw Exception(message);
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

  // تسجيل مستخدم جديد
  Future<UserCredential> registerUser({
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // التحقق من توفر اسم المستخدم
      final isUsernameAvailable = await _checkUsernameAvailability(username);
      if (!isUsernameAvailable) {
        throw Exception('Username is already taken');
      }

      // التحقق من توفر البريد الإلكتروني
      final isEmailAvailable = await _checkEmailAvailability(email);
      if (!isEmailAvailable) {
        throw Exception('Email is already registered');
      }

      // إنشاء المستخدم
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      // حفظ بيانات المستخدم
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username.toLowerCase(),
        'fullName': fullName,
        'email': email.toLowerCase(),
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
      }
      throw Exception(message);
    }
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.toLowerCase());
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        default:
          message = 'Password reset failed: ${e.message}';
      }
      throw Exception(message);
    }
  }

  // تحديث البريد الإلكتروني
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not found');
      }

      // التحقق من توفر البريد الإلكتروني الجديد
      final isEmailAvailable = await _checkEmailAvailability(newEmail);
      if (!isEmailAvailable) {
        throw Exception('Email is already registered');
      }

      // إعادة المصادقة
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // تحديث البريد الإلكتروني
      await user.verifyBeforeUpdateEmail(newEmail.toLowerCase());
      
      // تحديث Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail.toLowerCase(),
      });
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'requires-recent-login':
          message = 'Please log in again before updating email';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'email-already-in-use':
          message = 'Email is already registered';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        default:
          message = 'Failed to update email: ${e.message}';
      }
      throw Exception(message);
    }
  }

  // تغيير كلمة المرور
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not found');
      }

      // إعادة المصادقة
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // تحديث كلمة المرور
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'New password is too weak';
          break;
        case 'requires-recent-login':
          message = 'Please log in again before changing password';
          break;
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        default:
          message = 'Failed to change password: ${e.message}';
      }
      throw Exception(message);
    }
  }

  // التحقق من توفر اسم المستخدم
  Future<bool> _checkUsernameAvailability(String username) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }

  // التحقق من توفر البريد الإلكتروني
  Future<bool> _checkEmailAvailability(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }
}