import 'package:equatable/equatable.dart';
import '../../../domain/entities/prospect_status.dart';

enum ProspectStatusEnum { initial, loading, loaded, error }

class ProspectStatusState extends Equatable {
  final ProspectStatusEnum status;
  final List<ProspectStatus> statuses;
  final String? errorMessage;

  const ProspectStatusState({
    this.status = ProspectStatusEnum.initial,
    this.statuses = const [],
    this.errorMessage,
  });

  ProspectStatusState copyWith({
    ProspectStatusEnum? status,
    List<ProspectStatus>? statuses,
    String? errorMessage,
  }) {
    return ProspectStatusState(
      status: status ?? this.status,
      statuses: statuses ?? this.statuses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, statuses, errorMessage];
}
