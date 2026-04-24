import '../../../domain/entities/chat_message_entity.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final ChatHistory chatHistory;
  final bool isFetchingMore;

  MessageLoaded(this.chatHistory, {this.isFetchingMore = false});
}

class MessageError extends MessageState {
  final String message;

  MessageError(this.message);
}