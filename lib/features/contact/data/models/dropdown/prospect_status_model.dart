import '../../../domain/entities/prospect/prospect_status.dart';

class ProspectStatusModel extends ProspectStatus {
  const ProspectStatusModel({
    required super.statusProspectId,
    required super.statusProspectName,
  });

  factory ProspectStatusModel.fromJson(Map<String, dynamic> json) {
    return ProspectStatusModel(
      statusProspectId: json['status_prospect_id'] as int,
      statusProspectName: json['status_prospect_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_prospect_id': statusProspectId,
      'status_prospect_name': statusProspectName,
    };
  }
}
