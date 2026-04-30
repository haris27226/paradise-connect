import 'package:equatable/equatable.dart';

class ProspectStatus extends Equatable {
  final int statusProspectId;
  final String statusProspectName;

  const ProspectStatus({
    required this.statusProspectId,
    required this.statusProspectName,
  });

  @override
  List<Object?> get props => [statusProspectId, statusProspectName];
}
