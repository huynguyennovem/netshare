import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/connection_status.dart';
import 'package:netshare/entity/function_mode.dart';
import 'package:netshare/entity/message.dart';
import 'package:netshare/entity/message_state.dart';
import 'package:netshare/provider/app_provider.dart';
import 'package:netshare/provider/chat_provider.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/service/message_manage_service.dart';
import 'package:netshare/ui/chat/list_message_widget.dart';
import 'package:netshare/ui/common_view/app_field_widget.dart';
import 'package:netshare/ui/common_view/connection_status_info.dart';
import 'package:netshare/util/extension.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

///
/// Be used for both Client and Server widget
///
class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _textController = TextEditingController();
  String _fromIPAddress = '';
  String _toIPAddress = '';
  FunctionMode appMode = FunctionMode.none;

  // use WebSocketChannel (provided by web_socket_channel package) instead of WebSocket
  // for synchronize initializing (not async like WebSocket)
  late WebSocketChannel _webSocketChannel;

  @override
  void initState() {
    super.initState();
    _initialize();
    _handleMessageStream();
    _handleSocket();
  }

  @override
  void dispose() {
    _textController.dispose();
    _webSocketChannel.sink.close();
    super.dispose();
  }

  void _initialize() {
    _fromIPAddress = getIt.get<GlobalScopeData>().currentDeviceIPAddress;
    if (mounted) {
      appMode = context.read<AppProvider>().appMode;
      final clientConnectionIP = context.read<ConnectionProvider>().connectedIPAddress;
      if (appMode == FunctionMode.server) {
        _toIPAddress = _fromIPAddress;
      } else if (appMode == FunctionMode.client) {
        final ip = clientConnectionIP.split(':'); // parse address, only get IP, without port
        _toIPAddress = ip[0];
      }
    }
  }

  void _handleMessageStream() {
    getIt.get<MessageManagerService>().messageStreamController.listen((message) {
      debugPrint("[ChatWidget] Message stream log: $message");
      if (mounted) {
        context
            .read<ChatProvider>()
            .updateMessage(sourceMessage: message, messageState: message.messageState);
      }
      // TODO update state to DB
    });
  }

  void _handleSocket() {
    // Get endpoint for connecting to socket
    // connectedIPAddress is only available when client connected to server
    // for server instance, need to concat endpoint manually
    // The final endpoint will be the same; for eg: 192.168.a.b:8080/message
    String endpoint = '';
    if (appMode == FunctionMode.client) {
      endpoint = 'ws://${getIt.get<GlobalScopeData>().connectedIPAddress}/message';
    } else if (appMode == FunctionMode.server) {
      endpoint = 'ws://'
          '${getIt.get<GlobalScopeData>().currentDeviceIPAddress}'
          ':'
          '${getIt.get<GlobalScopeData>().currentServerHostingPort}'
          '/message';
    }

    _webSocketChannel = WebSocketChannel.connect(Uri.parse(endpoint));
    debugPrint("[ChatWidget] Connected to websocket: $endpoint");

    _webSocketChannel.stream.listen((response) {
      print('response from ws: $response');
      // Client: add SENT message to stream
      // No need to do the same for server as it's already done on ServerWidget
      if (appMode == FunctionMode.client) {
        final sentMessage = Message.fromJson(json.decode(response));
        getIt.get<MessageManagerService>().addMessage(sentMessage);
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(
      builder: (BuildContext context, ConnectionProvider connection, Widget? child) {
        final connectionStatus = connection.connectionStatus;
        final connectedIPAddress = connection.connectedIPAddress;
        final isConnected = connectionStatus == ConnectionStatus.connected;
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scaffold(
            appBar: AppBar(
              elevation: 4.0,
              title: isConnected
                  ? ConnectionStatusInfo(
                      isConnected: isConnected,
                      connectedIPAddress: connectedIPAddress,
                    )
                  : Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Chat',
                        style: CommonTextStyle.textStyleAppbar,
                      ),
                    ),
            ),
            body: Column(
              children: [
                Flexible(child: ListMessageWidget(sendingAddress: _fromIPAddress)),
                _messageInput(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _messageInput() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Expanded(
            child: AppFieldWidget(
              textController: _textController,
              backgroundColor: Colors.black12,
            ),
          ),
          const SizedBox(width: 4.0),
          IconButton.outlined(
            onPressed: () => _sendMessage(),
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;
    if (_toIPAddress.isEmpty || _fromIPAddress.isEmpty) return;

    final message = Message(
      text: _textController.text.trim(),
      sender: _fromIPAddress,
      receiver: _toIPAddress,
      createdTime: DateTime.now(),
      messageState: MessageState.sending,
      messageRole: appMode.toMessageRole(),
    );
    debugPrint("[ChatWidget] Message is sending: $message");

    // Client || Server: sending message to socket
    final data = json.encode(message.toJson());
    _webSocketChannel.sink.add(data);

    if (mounted) {
      // Client: add SENDING message to provider
      if (appMode == FunctionMode.client) {
        context.read<ChatProvider>().addMessage(message: message);
      }
    }

    // final stuffs
    // TODO: add message to DB
    _textController.clear();
  }
}
