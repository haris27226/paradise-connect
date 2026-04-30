import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final int contactId;
  final String? hubspotContactId;
  final bool? isSyncHubspot;
  final String? salutation;
  final String? fullName;
  final String? primaryPhone;
  final String? whatsappNumber;
  final String? primaryEmail;
  final String? noKtp;
  final String? ktpAddress;
  final String? firstProject;
  final String? lastProject;
  final String? firstProduct;
  final String? lastProduct;
  final int? salesChannelId;
  final String? sumberInformasi2;
  final String? firstProjectCategory;
  final String? lastProjectCategory;
  final String? firstBlokNo;
  final String? lastBlokNo;
  final int? salesExecutiveId;
  final int? salesSupervisorId;
  final int? salesManagerId;
  final int? salesTeamId;
  final int? statusProspectId;
  final String? volumePlan;
  final int? visitCount;
  final String? generalNotes;
  final String? firstApptDate;
  final String? lastApptDate;
  final String? firstVisitDate;
  final String? lastVisitDate;
  final String? firstReserveDate;
  final String? lastReserveDate;
  final String? firstSpDate;
  final String? lastSpDate;
  final String? firstAkadDate;
  final String? lastAkadDate;
  final String? firstLostDate;
  final String? lastLostDate;
  final dynamic propertiesJson;
  final int? ownerId;
  final int? dealId;
  final List<dynamic>? propertyGroupsJson;
  final String? dealValue;
  final String? apptDate;
  final String? visitDate;
  final String? dealNote;
  final String? projectName;
  final String? blokNo;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const Contact({
    required this.contactId,
    this.hubspotContactId,
    this.isSyncHubspot,
    this.salutation,
    this.fullName,
    this.primaryPhone,
    this.whatsappNumber,
    this.primaryEmail,
    this.noKtp,
    this.ktpAddress,
    this.firstProject,
    this.lastProject,
    this.firstProduct,
    this.lastProduct,
    this.salesChannelId,
    this.sumberInformasi2,
    this.firstProjectCategory,
    this.lastProjectCategory,
    this.firstBlokNo,
    this.lastBlokNo,
    this.salesExecutiveId,
    this.salesSupervisorId,
    this.salesManagerId,
    this.salesTeamId,
    this.statusProspectId,
    this.volumePlan,
    this.visitCount,
    this.generalNotes,
    this.firstApptDate,
    this.lastApptDate,
    this.firstVisitDate,
    this.lastVisitDate,
    this.firstReserveDate,
    this.lastReserveDate,
    this.firstSpDate,
    this.lastSpDate,
    this.firstAkadDate,
    this.lastAkadDate,
    this.firstLostDate,
    this.lastLostDate,
    this.propertiesJson,
    this.ownerId,
    this.dealId,
    this.propertyGroupsJson,
    this.dealValue,
    this.apptDate,
    this.visitDate,
    this.dealNote,
    this.projectName,
    this.blokNo,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    contactId,
    hubspotContactId,
    isSyncHubspot,
    salutation,
    fullName,
    primaryPhone,
    whatsappNumber,
    primaryEmail,
    noKtp,
    ktpAddress,
    firstProject,
    lastProject,
    firstProduct,
    lastProduct,
    salesChannelId,
    sumberInformasi2,
    firstProjectCategory,
    lastProjectCategory,
    firstBlokNo,
    lastBlokNo,
    salesExecutiveId,
    salesSupervisorId,
    salesManagerId,
    salesTeamId,
    statusProspectId,
    volumePlan,
    visitCount,
    generalNotes,
    firstApptDate,
    lastApptDate,
    firstVisitDate,
    lastVisitDate,
    firstReserveDate,
    lastReserveDate,
    firstSpDate,
    lastSpDate,
    firstAkadDate,
    lastAkadDate,
    firstLostDate,
    lastLostDate,
    propertiesJson,
    ownerId,
    dealId,
    propertyGroupsJson,
    dealValue,
    apptDate,
    visitDate,
    dealNote,
    projectName,
    blokNo,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
