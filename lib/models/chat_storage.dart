// chat_storage.dart
import 'package:loan_app/models/chat.dart';

class ChatStorage {
  static final ChatStorage _instance = ChatStorage._internal();
  factory ChatStorage() => _instance;
  ChatStorage._internal();

  List<ModelMessage> messages = [];
}
