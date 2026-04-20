// lib/features/inbox/domain/usecases/get_messages_usecase.dart

import 'package:progress_group/features/inbox/domain/repositories/message_repository.dart';

import '../entities/chat_message_entity.dart';

class GetMessagesUseCase {
  final MessageRepository repository;

  GetMessagesUseCase(this.repository);

  Future<ChatHistory> call(String sessionId, String jid) {
    return repository.getMessages(sessionId, jid);
  }
}