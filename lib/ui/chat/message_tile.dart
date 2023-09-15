import 'package:flutter/material.dart';
import 'package:netshare/entity/message.dart';
import 'package:netshare/entity/message_state.dart';

class MessageTile extends StatefulWidget {
  final Message message;
  final String sendingAddress;

  const MessageTile({super.key, required this.message, required this.sendingAddress});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return _buildBubble(widget.sendingAddress == widget.message.sender);
  }

  _buildBubble(bool isSender) => Container(
    margin: const EdgeInsets.only(top: 2.0, left: 4.0, right: 4.0),
    child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            isSender ? const SizedBox.shrink() : const Icon(Icons.computer),
            const SizedBox(width: 2.0),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                decoration: ShapeDecoration(
                  color: isSender ? Colors.lightBlue : Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  widget.message.text,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            isSender ? Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                width: 12.0,
                height: 12.0,
                child: _sendingStatus(),
              ),
            ) : const SizedBox.shrink(),
          ],
        ),
  );

  Widget _sendingStatus() {
    switch (widget.message.messageState) {
      case MessageState.sending:
        return const CircularProgressIndicator(strokeWidth: 2.0);
      case MessageState.sent:
        return const Icon(Icons.check_circle, color: Colors.blue, size: 14.0);
      case MessageState.error:
        return const Icon(Icons.error, color: Colors.redAccent, size: 14.0);
    }
  }
}
