import 'package:equatable/equatable.dart';

class ProspectStatusEntity extends Equatable {
  final int statusProspectId;
  final String statusProspectName;

  const ProspectStatusEntity({
    required this.statusProspectId,
    required this.statusProspectName,
  });

  @override
  List<Object?> get props => [statusProspectId, statusProspectName];
}
