// lib/services/service_service.dart

import 'package:carcare/models/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة خدمة جديدة
  Future<void> addService(Service service) async {
    try {
      await _firestore.collection('services').add(service.toMap());
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }

  // تحديث خدمة موجودة
  Future<void> updateService(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('services').doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  // حذف خدمة
  Future<void> deleteService(String id) async {
    try {
      await _firestore.collection('services').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  // جلب خدمات الشركة
  Stream<QuerySnapshot> getCompanyServicesStream(String companyId) {
    return _firestore
        .collection('services')
        .where('company_id', isEqualTo: companyId)
        .snapshots();
  }

  // جلب خدمة محددة
  Future<Service?> getService(String id) async {
    try {
      final doc = await _firestore.collection('services').doc(id).get();
      if (!doc.exists) return null;
      return Service.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }
}