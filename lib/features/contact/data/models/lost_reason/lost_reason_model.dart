import 'package:progress_group/features/contact/domain/entities/lost_reason/lost_reason_entity.dart';

class LostReasonModel extends LostReasonEntity {
  const LostReasonModel({
    required super.lostReasonId,
    required super.lostReasonName,
  });

  factory LostReasonModel.fromJson(Map<String, dynamic> json) {
    return LostReasonModel(
      lostReasonId: json['lost_reason_id'] as int,
      lostReasonName: json['lost_reason_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lost_reason_id': lostReasonId,
      'lost_reason_name': lostReasonName,
    };
  }
}