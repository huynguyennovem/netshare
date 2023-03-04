import 'package:flutter/material.dart';

class AddressFieldWidget extends StatelessWidget {
  final TextEditingController ipTextController;
  final TextEditingController portTextController;

  final bool? isEnableIP;
  final bool? isEnablePort;

  const AddressFieldWidget({
    Key? key,
    required this.ipTextController,
    required this.portTextController,
    this.isEnableIP,
    this.isEnablePort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: isEnableIP ?? true,
            controller: ipTextController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '192.168.1.100',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        SizedBox(
          width: 72.0,
          child: TextField(
            enabled: isEnablePort ?? true,
            controller: portTextController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '8080',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
