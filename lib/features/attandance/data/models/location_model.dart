import 'package:progress_group/features/attandance/domain/entities/location_entity.dart';

class AttendanceLocationModel extends AttendanceLocation {
  AttendanceLocationModel({
    required super.id,
    required super.name,
    super.latitude,
    super.longitude,
    super.radius,
  });

  factory AttendanceLocationModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLocationModel(
      id: json['location_id'],
      name: json['location_name'] ?? '',
      latitude: json['latitude'] is String ? double.tryParse(json['latitude']) : (json['latitude'] as num?)?.toDouble(),
      longitude: json['longitude'] is String ? double.tryParse(json['longitude']) : (json['longitude'] as num?)?.toDouble(),
      radius: json['radius_meter'],
    );
  }
}
