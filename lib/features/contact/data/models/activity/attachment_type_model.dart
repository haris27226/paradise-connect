import '../../../domain/entities/attachment/attachment_type.dart';

class AttachmentTypeModel extends AttachmentType {
  AttachmentTypeModel({required super.id, required super.name});

  factory AttachmentTypeModel.fromJson(Map<String, dynamic> json) {
    return AttachmentTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}