import 'package:equatable/equatable.dart';

// class CreateContactParams extends Equatable {
//   final String fullName;
//   final String salutation;
//   final String primaryPhone;
//   final String? primaryEmail;
//   final String? whatsappNumber;
//   final String? firstProject;
//   final String? firstProduct;
//   final String? firstProjectCategory;
//   final String? firstBlokNo;
//   final int? salesExecutiveId;
//   final int? salesManagerId;
//   final int? salesSupervisorId;
//   final int? salesTeamId;
//   final int? salesChannelId;
//   final int? statusProspectId;
//   final String? sumberInformasi2;
//   final String? generalNotes;
//   final Map<String, dynamic>? properties;
//   final List<Map<String, dynamic>>? propertiesJson;

//   const CreateContactParams({
//     required this.fullName,
//     required this.salutation,
//     required this.primaryPhone,
//     this.primaryEmail,
//     this.whatsappNumber,
//     this.firstProject,
//     this.firstProduct,
//     this.firstProjectCategory,
//     this.firstBlokNo,
//     this.salesExecutiveId,
//     this.salesManagerId,
//     this.salesSupervisorId,
//     this.salesTeamId,
//     this.salesChannelId,
//     this.statusProspectId,
//     this.sumberInformasi2,
//     this.generalNotes,
//     this.properties,
//     this.propertiesJson,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'full_name': fullName,
//       'salutation': salutation,
//       'primary_phone': primaryPhone,
//       if (primaryEmail != null) 'primary_email': primaryEmail,
//       if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
//       if (firstProject != null) 'first_project': firstProject,
//       if (firstProduct != null) 'first_product': firstProduct,
//       if (firstProjectCategory != null)
//         'first_project_category': firstProjectCategory,
//       if (firstBlokNo != null) 'first_blok_no': firstBlokNo,
//       if (salesExecutiveId != null) 'sales_executive_id': salesExecutiveId,
//       if (salesManagerId != null) 'sales_manager_id': salesManagerId,
//       if (salesSupervisorId != null) 'sales_supervisor_id': salesSupervisorId,
//       if (salesTeamId != null) 'sales_team_id': salesTeamId,
//       if (salesChannelId != null) 'sales_channel_id': salesChannelId,
//       if (statusProspectId != null) 'status_prospect_id': statusProspectId,
//       if (sumberInformasi2 != null) 'sumber_informasi_2': sumberInformasi2,
//       if (generalNotes != null) 'general_notes': generalNotes,
//       if (properties != null) 'properties': properties,
//       if (propertiesJson != null) 'properties_json': propertiesJson,
//     };
//   }

//   @override
//   List<Object?> get props => [
//     fullName,
//     salutation,
//     primaryPhone,
//     primaryEmail,
//     whatsappNumber,
//     firstProject,
//     firstProduct,
//     firstProjectCategory,
//     firstBlokNo,
//     salesExecutiveId,
//     salesManagerId,
//     salesSupervisorId,
//     salesTeamId,
//     salesChannelId,
//     statusProspectId,
//     sumberInformasi2,
//     generalNotes,
//     properties,
//   ];
// }

class CreateContactParams extends Equatable {
  final String fullName;
  final String salutation;
  final String primaryPhone;
  final String? primaryEmail;
  final String? whatsappNumber;
  final String? noKtp;
  final String? ktpAddress;
  final String? firstProject;
  final String? lastProject;
  final String? firstProduct;
  final String? lastProduct;
  final String? firstProjectCategory;
  final String? lastProjectCategory;
  final String? firstBlokNo;
  final String? lastBlokNo;
  final int? salesExecutiveId;
  final int? salesManagerId;
  final int? salesSupervisorId;
  final int? salesTeamId;
  final int? salesChannelId;
  final int? statusProspectId;
  final String? sumberInformasi2;
  final String? volumePlan;
  final int? visitCount;
  final String? generalNotes;
  final String? firstApptDate;
  final String? lastApptDate;
  final String? firstVisitDate;
  final String? lastVisitDate;
  final String? firstSPDate;
  final String? lastSPDate;
  final String? reserveDate;
  final String? lastReserveDate;
  final String? dealValue;
  final String? lossReasonNote;
  final Map<String, dynamic>? properties;
  final List<Map<String, dynamic>>? propertiesJson;

  const CreateContactParams({
    required this.fullName,
    required this.salutation,
    required this.primaryPhone,
    this.primaryEmail,
    this.whatsappNumber,
    this.noKtp,
    this.ktpAddress,
    this.firstProject,
    this.lastProject,
    this.firstProduct,
    this.lastProduct,
    this.firstProjectCategory,
    this.lastProjectCategory,
    this.firstBlokNo,
    this.lastBlokNo,
    this.salesExecutiveId,
    this.salesManagerId,
    this.salesSupervisorId,
    this.salesTeamId,
    this.salesChannelId,
    this.statusProspectId,
    this.sumberInformasi2,
    this.volumePlan,
    this.visitCount,
    this.generalNotes,
    this.firstApptDate,
    this.lastApptDate,
    this.firstVisitDate,
    this.lastVisitDate,
    this.firstSPDate,
    this.lastSPDate,
    this.reserveDate,
    this.lastReserveDate,
    this.dealValue,
    this.lossReasonNote,
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
      if (noKtp != null) 'no_ktp': noKtp,
      if (ktpAddress != null) 'ktp_address': ktpAddress,
      if (firstProject != null) 'first_project': firstProject,
      if (lastProject != null) 'last_project': lastProject,
      if (firstProduct != null) 'first_product': firstProduct,
      if (lastProduct != null) 'last_product': lastProduct,
      if (firstProjectCategory != null)
        'first_project_category': firstProjectCategory,
      if (lastProjectCategory != null)
        'last_project_category': lastProjectCategory,
      if (firstBlokNo != null) 'first_blok_no': firstBlokNo,
      if (lastBlokNo != null) 'last_blok_no': lastBlokNo,
      if (salesExecutiveId != null) 'sales_executive_id': salesExecutiveId,
      if (salesManagerId != null) 'sales_manager_id': salesManagerId,
      if (salesSupervisorId != null) 'sales_supervisor_id': salesSupervisorId,
      if (salesTeamId != null) 'sales_team_id': salesTeamId,
      if (salesChannelId != null) 'sales_channel_id': salesChannelId,
      if (statusProspectId != null) 'status_prospect_id': statusProspectId,
      if (sumberInformasi2 != null) 'sumber_informasi_2': sumberInformasi2,
      if (volumePlan != null) 'volume_plan': volumePlan,
      if (visitCount != null) 'visit_count': visitCount,
      if (generalNotes != null) 'general_notes': generalNotes,
      if (firstApptDate != null) 'first_appt_date': firstApptDate,
      if (lastApptDate != null) 'last_appt_date': lastApptDate,
      if (firstVisitDate != null) 'first_visit_date': firstVisitDate,
      if (lastVisitDate != null) 'last_visit_date': lastVisitDate,
      if (dealValue != null) 'deal_value': dealValue,
      if (lossReasonNote != null) 'loss_reason_note': lossReasonNote,
      if (firstSPDate != null) 'first_sp_date': firstSPDate,
      if (lastSPDate != null) 'last_sp_date': lastSPDate,
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
    noKtp,
    ktpAddress,
    firstProject,
    lastProject,
    firstProduct,
    lastProduct,
    firstProjectCategory,
    lastProjectCategory,
    firstBlokNo,
    lastBlokNo,
    salesExecutiveId,
    salesManagerId,
    salesSupervisorId,
    salesTeamId,
    salesChannelId,
    statusProspectId,
    sumberInformasi2,
    volumePlan,
    visitCount,
    generalNotes,
    firstApptDate,
    lastApptDate,
    firstVisitDate,
    lastVisitDate,
    dealValue,
    lossReasonNote,
    firstSPDate,
    lastSPDate,
    properties,
    propertiesJson,
  ];
}
