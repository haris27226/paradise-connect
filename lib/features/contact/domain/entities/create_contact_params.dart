import 'package:equatable/equatable.dart';

class CreateContactParams extends Equatable {
  final String fullName;
  final String salutation;
  final String primaryPhone;
  final String? primaryEmail;
  final String? whatsappNumber;
  final String? firstProject;
  final String? firstProduct;
  final String? firstProjectCategory;
  final String? firstBlokNo;
  final int? salesExecutiveId;
  final int? salesManagerId;
  final int? salesSupervisorId;
  final int? salesTeamId;
  final int? salesChannelId;
  final int? statusProspectId;
  final String? sumberInformasi2;
  final String? generalNotes;
  final Map<String, dynamic>? properties;
  final List<Map<String, dynamic>>? propertiesJson;

  const CreateContactParams({
    required this.fullName,
    required this.salutation,
    required this.primaryPhone,
    this.primaryEmail,
    this.whatsappNumber,
    this.firstProject,
    this.firstProduct,
    this.firstProjectCategory,
    this.firstBlokNo,
    this.salesExecutiveId,
    this.salesManagerId,
    this.salesSupervisorId,
    this.salesTeamId,
    this.salesChannelId,
    this.statusProspectId,
    this.sumberInformasi2,
    this.generalNotes,
    this.properties,
    this.propertiesJson,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'salutation': salutation,
      'primary_phone': primaryPhone,
      if (primaryEmail != null) 'primary_email': primaryEmail,
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      if (firstProject != null) 'first_project': firstProject,
      if (firstProduct != null) 'first_product': firstProduct,
      if (firstProjectCategory != null)
        'first_project_category': firstProjectCategory,
      if (firstBlokNo != null) 'first_blok_no': firstBlokNo,
      if (salesExecutiveId != null) 'sales_executive_id': salesExecutiveId,
      if (salesManagerId != null) 'sales_manager_id': salesManagerId,
      if (salesSupervisorId != null) 'sales_supervisor_id': salesSupervisorId,
      if (salesTeamId != null) 'sales_team_id': salesTeamId,
      if (salesChannelId != null) 'sales_channel_id': salesChannelId,
      if (statusProspectId != null) 'status_prospect_id': statusProspectId,
      if (sumberInformasi2 != null) 'sumber_informasi_2': sumberInformasi2,
      if (generalNotes != null) 'general_notes': generalNotes,
      if (properties != null) 'properties': properties,
      if (propertiesJson != null) 'properties_json': propertiesJson,
    };
  }

  @override
  List<Object?> get props => [
    fullName,
    salutation,
    primaryPhone,
    primaryEmail,
    whatsappNumber,
    firstProject,
    firstProduct,
    firstProjectCategory,
    firstBlokNo,
    salesExecutiveId,
    salesManagerId,
    salesSupervisorId,
    salesTeamId,
    salesChannelId,
    statusProspectId,
    sumberInformasi2,
    generalNotes,
    properties,
  ];
}
