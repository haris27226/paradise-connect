import '../../domain/entities/sales_manager.dart';

class SalesManagerModel extends SalesManager {
  const SalesManagerModel({
    required super.salesPersonId,
    required super.fullName,
    super.salesPersonCode,
  });

  factory SalesManagerModel.fromJson(Map<String, dynamic> json) {
    return SalesManagerModel(
      salesPersonId: json['sales_person_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      salesPersonCode: json['sales_person_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sales_person_id': salesPersonId,
      'full_name': fullName,
      if (salesPersonCode != null) 'sales_person_code': salesPersonCode,
    };
  }
}
