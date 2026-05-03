import 'dart:io';

import 'dart:typed_data';

class CreateVisitParams {
  final int contactId;
  final int statusProspectId;
  final int visitCount;
  final String activityDate;
  final String notes;
  final File? file;
  final Uint8List? fileBytes;
  final String? fileName;

  CreateVisitParams({
    required this.contactId,
    required this.statusProspectId,
    required this.visitCount,
    required this.activityDate,
    required this.notes,
    this.file,
    this.fileBytes,
    this.fileName,
  });
}