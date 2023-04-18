import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/connection_status.dart';
import 'package:netshare/util/extension.dart';

class NavigationWidgets extends StatefulWidget {
  final ConnectionStatus connectionStatus;

  const NavigationWidgets({Key? key, required this.connectionStatus}) : super(key: key);

  @override
  State<NavigationWidgets> createState() => _NavigationWidgetsState();
}

class _NavigationWidgetsState extends State<NavigationWidgets> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Builder(builder: (context) {
            return FloatingActionButton.extended(
              backgroundColor: widget.connectionStatus == ConnectionStatus.connected
                ? Colors.blueAccent
                : Colors.grey,
              heroTag: const Text('Send'),
              onPressed: () => _onClickSend(),
              icon: const Icon(Icons.send, color: Colors.white),
              label: Text(
                'Send',
                style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
              ),
            );
          }),
          const SizedBox(width: 20),
          FloatingActionButton.extended(
            backgroundColor: widget.connectionStatus == ConnectionStatus.connected
              ? Colors.blueAccent
              : Colors.grey,
            heroTag: const Text("Receive"),
            onPressed: () => _onClickReceive(),
            icon: const Icon(Icons.download, color: Colors.white),
            label: Text(
              'Receive',
              style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _onClickSend() {
    if(widget.connectionStatus != ConnectionStatus.connected) return;
    context.pushNamed(mSendPath);
  }

  void _onClickReceive() {
    // if(widget.connectionStatus != ConnectionStatus.connected) return;
    // context.pushNamed(mReceivePath);
    context.showSnackbar('This feature is under development!');
  }
}
