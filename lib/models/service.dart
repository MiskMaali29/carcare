// lib/models/service.dart

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // بالدقائق
 // final String companyId;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    //required this.companyId,
  });

  factory Service.fromFirestore(Map<String, dynamic> data, String id) {
    return Service(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : double.tryParse(data['price']?.toString() ?? '0') ?? 0.0,
      duration: (data['duration'] is num) ? (data['duration'] as num).toInt() : int.tryParse(data['duration']?.toString() ?? '30') ?? 30,
    //  companyId: data['company_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
    //  'company_id': companyId,
    };
  }
}