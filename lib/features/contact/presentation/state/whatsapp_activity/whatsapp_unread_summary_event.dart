import 'package:equatable/equatable.dart';

abstract class WhatsappUnreadSummaryEvent extends Equatable {
  const WhatsappUnreadSummaryEvent();

  @override
  List<Object> get props => [];
}

class FetchWhatsappUnreadSummaryEvent extends WhatsappUnreadSummaryEvent {
  final int contactId;

  const FetchWhatsappUnreadSummaryEvent(this.contactId);

  @override
  List<Object> get props => [contactId];
}