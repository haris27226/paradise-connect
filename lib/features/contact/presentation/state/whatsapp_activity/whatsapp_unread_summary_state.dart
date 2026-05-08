import 'package:equatable/equatable.dart';
import 'package:progress_group/features/contact/domain/entities/activity/whatsapp_activity_entity.dart';


enum WhatsappUnreadSummaryStatus {
  initial,
  loading,
  loaded,
  error,
}

class WhatsappActivityState extends Equatable {
  final WhatsappUnreadSummaryStatus status;
  final List<WhatsappUnreadSummaryEntity> data;
  final String? errorMessage;

  const WhatsappActivityState({
    this.status = WhatsappUnreadSummaryStatus.initial,
    this.data = const [],
    this.errorMessage,
  });

  WhatsappActivityState copyWith({
    WhatsappUnreadSummaryStatus? status,
    List<WhatsappUnreadSummaryEntity>? data,
    String? errorMessage,
  }) {
    return WhatsappActivityState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        errorMessage,
      ];
}