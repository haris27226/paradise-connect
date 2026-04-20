import '../../../domain/entities/chat_message_entity.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final ChatHistory chatHistory;

  MessageLoaded(this.chatHistory);
}

class MessageError extends MessageState {
  final String message;

  MessageError(this.message);
}