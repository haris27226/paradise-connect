import 'package:progress_group/features/contact/domain/entities/lost_reason/lost_reason_entity.dart';

class LostReasonModel extends LostReasonEntity {
  const LostReasonModel({
    required super.id,
    required super.text,
  });

  factory LostReasonModel.fromJson(Map<String, dynamic> json) {
    return LostReasonModel(
      id: json['id'] as int,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}