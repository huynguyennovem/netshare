import 'package:flutter/material.dart';
import 'package:netshare/provider/chat_provider.dart';
import 'package:netshare/ui/chat/message_tile.dart';
import 'package:provider/provider.dart';

class ListMessageWidget extends StatefulWidget {
  const ListMessageWidget({super.key, required this.sendingAddress});
  final String sendingAddress;

  @override
  State<ListMessageWidget> createState() => _ListMessageWidgetState();
}

class _ListMessageWidgetState extends State<ListMessageWidget> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (BuildContext context, ChatProvider chat, Widget? child) {
        debugPrint('[ListMessageWidget] Messages in tree: ${chat.messages.length}');
        return ListView.builder(
          reverse: true,
          itemCount: chat.messages.length,
          itemBuilder: (context, index) => MessageTile(
            message: chat.messages.reversed.toList()[index],
            sendingAddress: widget.sendingAddress,
          ),
        );
      },
    );
  }
}
