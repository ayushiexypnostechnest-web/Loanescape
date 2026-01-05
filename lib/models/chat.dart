import 'dart:io';

class ModelMessage {
  final bool isPrompt;
  final String message;
  final DateTime time;
  final File? image; 

  ModelMessage({
    required this.isPrompt,
    required this.message,
    required this.time,
    this.image,
  });
}
