import '../../domain/entities/sales_executive.dart';

class SalesExecutiveModel extends SalesExecutive {
  const SalesExecutiveModel({
    required super.salesPersonId,
    required super.fullName,
    super.salesPersonCode,
  });

  factory SalesExecutiveModel.fromJson(Map<String, dynamic> json) {
    return SalesExecutiveModel(
      salesPersonId: json['sales_person_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      salesPersonCode: json['sales_person_code'],
    );
  }
}
