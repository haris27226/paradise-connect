import '../../../domain/entities/contact/contact.dart';

class ContactModel extends Contact {
  const ContactModel({
    required super.contactId,
    super.hubspotContactId,
    super.isSyncHubspot,
    super.salutation,
    super.fullName,
    super.primaryPhone,
    super.whatsappNumber,
    super.primaryEmail,
    super.noKtp,
    super.ktpAddress,
    super.firstProject,
    super.lastProject,
    super.firstProduct,
    super.lastProduct,
    super.salesChannelId,
    super.sumberInformasi2,
    super.firstProjectCategory,
    super.lastProjectCategory,
    super.firstBlokNo,
    super.lastBlokNo,
    super.salesExecutiveId,
    super.salesSupervisorId,
    super.salesManagerId,
    super.salesTeamId,
    super.statusProspectId,
    super.volumePlan,
    super.visitCount,
    super.generalNotes,
    super.firstApptDate,
    super.lastApptDate,
    super.firstVisitDate,
    super.lastVisitDate,
    super.firstReserveDate,
    super.lastReserveDate,
    super.firstSpDate,
    super.lastSpDate,
    super.firstAkadDate,
    super.lastAkadDate,
    super.firstLostDate,
    super.lastLostDate,
    super.propertiesJson,
    super.ownerId,
    super.dealId,
    super.propertyGroupsJson,
    dealValue,
    apptDate,
    visitDate,
    dealNote,
    projectName,
    blokNo,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      contactId: json['contact_id'],
      hubspotContactId: json['hubspot_contact_id']?.toString(),
      isSyncHubspot:
          json['is_sync_hubspot'] == 1 || json['is_sync_hubspot'] == true,
      salutation: json['salutation'],
      fullName: json['full_name'],
      primaryPhone: json['primary_phone'],
      whatsappNumber: json['whatsapp_number'],
      primaryEmail: json['primary_email'],
      noKtp: json['no_ktp']?.toString(),
      ktpAddress: json['ktp_address'],
      firstProject: json['first_project'],
      lastProject: json['last_project'],
      firstProduct: json['first_product'],
      lastProduct: json['last_product'],
      salesChannelId: json['sales_channel_id'] != null
          ? int.tryParse(json['sales_channel_id'].toString())
          : null,
      sumberInformasi2: json['sumber_informasi_2'],
      firstProjectCategory: json['first_project_category'],
      lastProjectCategory: json['last_project_category'],
      firstBlokNo: json['first_blok_no'],
      lastBlokNo: json['last_blok_no'],
      salesExecutiveId: json['sales_executive_id'] != null
          ? int.tryParse(json['sales_executive_id'].toString())
          : null,
      salesSupervisorId: json['sales_supervisor_id'] != null
          ? int.tryParse(json['sales_supervisor_id'].toString())
          : null,
      salesManagerId: json['sales_manager_id'] != null
          ? int.tryParse(json['sales_manager_id'].toString())
          : null,
      salesTeamId: json['sales_team_id'] != null
          ? int.tryParse(json['sales_team_id'].toString())
          : null,
      statusProspectId: json['status_prospect_id'] != null
          ? int.tryParse(json['status_prospect_id'].toString())
          : null,
      volumePlan: json['volume_plan']?.toString(),
      visitCount: json['visit_count'] != null
          ? int.tryParse(json['visit_count'].toString())
          : null,
      generalNotes: json['general_notes'],
      firstApptDate: json['first_appt_date'],
      lastApptDate: json['last_appt_date'],
      firstVisitDate: json['first_visit_date'],
      lastVisitDate: json['last_visit_date'],
      firstReserveDate: json['first_reserve_date'],
      lastReserveDate: json['last_reserve_date'],
      firstSpDate: json['first_sp_date'],
      lastSpDate: json['last_sp_date'],
      firstAkadDate: json['first_akad_date'],
      lastAkadDate: json['last_akad_date'],
      firstLostDate: json['first_lost_date'],
      lastLostDate: json['last_lost_date'],
      propertiesJson: json['properties_json'],
      ownerId: json['owner_id'] != null
          ? int.tryParse(json['owner_id'].toString())
          : null,
      dealId: json['deal_id'] != null
          ? int.tryParse(json['deal_id'].toString())
          : null,
      propertyGroupsJson: (json['property_groups'] as List<dynamic>?) ?? [],
      dealValue: json['deal_value'] != null
          ? json['deal_value'].toString()
          : null,
      apptDate: json['appt_date'],
      visitDate: json['visit_date'],
      dealNote: json['note'],
      projectName: json['project_name'],
      blokNo: json['blok_no'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }
}
