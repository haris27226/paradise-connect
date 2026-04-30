import 'package:progress_group/features/contact/domain/entities/attachment/attachment_entity.dart';


class ContactAttachmentModel extends ContactAttachment {
  ContactAttachmentModel({
    required super.contactAttachmentId,
    required super.contactId,
    super.dealId,
    super.activityId,
    required super.attachmentTypeId,
    required super.attachmentUrl,
    required super.attachmentTypeName,
    required super.attachmentNote,
    required super.createDatetime,
  });

  factory ContactAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ContactAttachmentModel(
      contactAttachmentId: json['contact_attachment_id'],
      contactId: json['contact_id'],
      dealId: json['deal_id'],
      activityId: json['activity_id'],
      attachmentTypeId: json['attachment_type_id'],
      attachmentUrl: json['attachment_url'] ?? '',
      attachmentTypeName: json['attachment_type_name'] ?? '',
      attachmentNote: json['attachment_note'] ?? '',
      createDatetime: DateTime.parse(json['create_datetime']),
    );
  }
}