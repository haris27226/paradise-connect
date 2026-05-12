import 'package:equatable/equatable.dart';
import 'package:progress_group/features/contact/domain/entities/lost_reason/lost_reason_entity.dart';

enum LostReasonStatus { initial, loading, loaded, error }

class LostReasonState extends Equatable {
  final LostReasonStatus status;
  final List<LostReasonEntity> reasons;
  final String? errorMessage;

  const LostReasonState({
    this.status = LostReasonStatus.initial,
    this.reasons = const [],
    this.errorMessage,
  });

  LostReasonState copyWith({
    LostReasonStatus? status,
    List<LostReasonEntity>? reasons,
    String? errorMessage,
  }) {
    return LostReasonState(
      status: status ?? this.status,
      reasons: reasons ?? this.reasons,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reasons, errorMessage];
}