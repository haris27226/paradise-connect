import '../../domain/entities/owner.dart';

class OwnerModel extends Owner {
  const OwnerModel({
    required super.salesPersonId,
    required super.fullName,
    super.salesPersonCode,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
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
