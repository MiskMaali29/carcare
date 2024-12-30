// lib/models/service.dart

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // بالدقائق
  final String companyId;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.companyId,
  });

  factory Service.fromFirestore(Map<String, dynamic> data, String id) {
    return Service(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      duration: data['duration'] ?? 30, // القيمة الافتراضية 30 دقيقة
      companyId: data['company_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'company_id': companyId,
    };
  }
}