class AttendanceLocation {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;
  final int? radius;

  AttendanceLocation({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.radius,
  });
}
