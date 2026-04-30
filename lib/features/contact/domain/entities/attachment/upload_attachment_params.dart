import 'dart:io';

class UploadAttachmentParams {
  final int contactId;
  final int? dealId;
  final int? activityId;
  final int attachmentTypeId;
  final String? attachmentNote;
  final File? file;

  UploadAttachmentParams({
    required this.contactId,
    this.dealId,
    this.activityId,
    required this.attachmentTypeId,
    this.attachmentNote,
    this.file,
  });
}
