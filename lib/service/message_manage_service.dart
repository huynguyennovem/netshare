import 'dart:async';

import 'package:netshare/entity/message.dart';

class MessageManagerService {
  final StreamController _messageStreamController = StreamController<Message>.broadcast();
  Stream<Message> get messageStreamController => _messageStreamController.stream as Stream<Message>;

  void disposeMessageStream() {
    _messageStreamController.close();
  }

  void addMessage(Message newMessage) {
    _messageStreamController.sink.add(newMessage);
  }

}