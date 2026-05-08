import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_group/features/contact/domain/usecases/activity/get_whatsapp_activity_usecase.dart';

import 'whatsapp_unread_summary_event.dart';
import 'whatsapp_unread_summary_state.dart';

class WhatsappActivityBloc extends Bloc< WhatsappUnreadSummaryEvent, WhatsappActivityState> {
  final GetWhatsappUnreadSummaryUseCase useCase;

  WhatsappActivityBloc(this.useCase): super(const WhatsappActivityState()) { 
    on<FetchWhatsappUnreadSummaryEvent>(_onFetch);
  }

  Future<void> _onFetch(FetchWhatsappUnreadSummaryEvent event, Emitter<WhatsappActivityState> emit,) async {
    emit(state.copyWith(status: WhatsappUnreadSummaryStatus.loading,));

    final result = await useCase(event.contactId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: WhatsappUnreadSummaryStatus.error,
        errorMessage: failure,
      )),
      (data) => emit(state.copyWith(
        status: WhatsappUnreadSummaryStatus.loaded,
        data: data,
      )),
    );
  }
}