import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_group/features/inbox/domain/usecases/get_messages_usecase.dart';
import 'package:progress_group/features/inbox/presentation/state/message/message_event.dart';
import 'package:progress_group/features/inbox/presentation/state/message/message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetMessagesUseCase getMessagesUseCase;

  MessageBloc(this.getMessagesUseCase) : super(MessageInitial()) {
    on<GetChatHistoryEvent>(_onGetChatHistory);
  }

  Future<void> _onGetChatHistory(
    GetChatHistoryEvent event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageLoading());

    try {
      final chatHistory = await getMessagesUseCase(event.sessionId, event.jid);
      emit(MessageLoaded(chatHistory));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }
}