import 'package:equatable/equatable.dart';

class ActivityProspectStatusEntity extends Equatable {
  final int historyId;
  final int dealId;
  final String projectName;
  final int statusProspectId;
  final String statusName;
  final int? previousStatusId;
  final String? previousStatusName;
  final String createdAt;

  const ActivityProspectStatusEntity({
    required this.historyId,
    required this.dealId,
    required this.projectName,
    required this.statusProspectId,
    required this.statusName,
    this.previousStatusId,
    this.previousStatusName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        historyId,
        dealId,
        projectName,
        statusProspectId,
        statusName,
        previousStatusId,
        previousStatusName,
        createdAt,
      ];
}