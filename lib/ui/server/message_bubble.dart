import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/message.dart';
import 'package:netshare/service/message_manage_service.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({super.key, required this.isServerStarted});

  final bool isServerStarted;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Message>(
        stream: getIt.get<MessageManagerService>().messageStreamController,
        builder: (context, snapshot) {
          final hasMessage = snapshot.hasData;
          return _buildBubble(hasMessage);
        });
  }

  Widget _buildBubble(bool hasMessage) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: const [
                  BoxShadow(
                    blurStyle: BlurStyle.outer,
                    blurRadius: 8.0,
                    color: Colors.black26,
                  ),
                ]),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 24.0,
              onPressed: () => _onClickMessageBubble(),
              icon: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.messenger_outlined, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
        hasMessage
            ? Container(
                margin: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
                child: const SizedBox(
                  width: 8,
                  height: 8,
                ))
            : const SizedBox.shrink(),
      ],
    );
  }

  _onClickMessageBubble() {
    if (!widget.isServerStarted) return;
    context.pushNamed(mChatPath);
  }
}
