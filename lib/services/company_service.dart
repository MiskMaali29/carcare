// lib/services/company_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyAuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل شركة جديدة
  Future<UserCredential> registerCompany({
    required String companyName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // إنشاء حساب في Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      // إضافة معلومات الشركة إلى Firestore
      await _firestore.collection('companies').doc(userCredential.user!.uid).set({
        'company_name': companyName,
        'username': username.toLowerCase(),
        'email': email.toLowerCase(),
        'role': 'company',
        'created_at': DateTime.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'فشل في تسجيل الشركة');
    }
  }

  // تسجيل دخول الشركة
  Future<UserCredential> loginCompany({
    required String email,
    required String password,
  }) async {
    try {
      // تسجيل الدخول باستخدام Firebase Authentication
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      // التحقق من أن الحساب هو حساب شركة
      DocumentSnapshot companyDoc = await _firestore
          .collection('companies')
          .doc(userCredential.user!.uid)
          .get();

      if (!companyDoc.exists || companyDoc.get('role') != 'company') {
        await auth.signOut();
        throw Exception('هذا ليس حساب شركة');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'فشل تسجيل الدخول');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await auth.signOut();
  }

  // الحصول على معلومات الشركة الحالية
  Future<Map<String, dynamic>?> getCurrentCompany() async {
    User? user = auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('companies')
          .doc(user.uid)
          .get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }
}