import 'package:flutter/material.dart';

class ReceiveWidget extends StatefulWidget {
  const ReceiveWidget({Key? key}) : super(key: key);

  @override
  State<ReceiveWidget> createState() => _ReceiveWidgetState();
}

class _ReceiveWidgetState extends State<ReceiveWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Hello')),
    );
  }
}
