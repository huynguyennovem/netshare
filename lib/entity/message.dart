import 'package:equatable/equatable.dart';
import 'package:netshare/entity/message_role.dart';
import 'package:netshare/entity/message_state.dart';
import 'package:netshare/util/extension.dart';

class Message extends Equatable {
  final String text;
  final String receiver;
  final String sender;
  final DateTime createdTime;
  final MessageState messageState;
  final MessageRole messageRole;
  final bool? isDeleted;

  const Message({
    required this.text,
    required this.receiver,
    required this.sender,
    required this.createdTime,
    required this.messageState,
    required this.messageRole,
    this.isDeleted = false,
  });

  Message copyWith({
    String? text,
    bool? isDeleted,
    MessageState? messageState,
    MessageRole? messageRole,
  }) =>
      Message(
        text: text ?? this.text,
        createdTime: createdTime,
        receiver: receiver,
        sender: sender,
        messageState: messageState ?? this.messageState,
        messageRole: messageRole ?? this.messageRole,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  factory Message.fromJson(dynamic json) => Message(
        text: json['text'],
        createdTime: DateTime.parse(json['createdTime']),
        receiver: json['receiver'],
        sender: json['sender'],
        messageState: MessageStateExtension.fromString(json['messageState']),
        messageRole: MessageRoleExtension.fromString(json['messageRole']),
        isDeleted: json['isDeleted'],
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['text'] = text;
    map['receiver'] = receiver;
    map['sender'] = sender;
    map['createdTime'] = createdTime.toIso8601String();
    map['messageState'] = messageState.value;
    map['messageRole'] = messageRole.value;
    map['isDeleted'] = isDeleted;
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Message &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          createdTime == other.createdTime;

  @override
  int get hashCode => super.hashCode ^ text.hashCode ^ createdTime.hashCode;

  @override
  List<Object?> get props => [text, createdTime];

  @override
  String toString() {
    return 'Message{text: $text, receiver: $receiver, sender: $sender, createdTime: $createdTime, messageState: $messageState, messageRole: $messageRole, isDeleted: $isDeleted}';
  }
}
