import 'package:flutter/material.dart';

class TwoSideTitleSwitch extends StatefulWidget {
  final bool switchInitValue;
  final Text leftValue;
  final Text rightValue;
  final Function(bool)? onValueChanged;

  const TwoSideTitleSwitch({
    Key? key,
    this.switchInitValue = false,
    required this.leftValue,
    required this.rightValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<TwoSideTitleSwitch> createState() => _TwoSideTitleSwitchState();
}

class _TwoSideTitleSwitchState extends State<TwoSideTitleSwitch> {
  bool switchValue = false;

  @override
  void initState() {
    super.initState();
    switchValue = widget.switchInitValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.leftValue,
        Switch(
          value: switchValue,
          onChanged: (bool value) {
            setState(() {
              switchValue = value;
            });
            widget.onValueChanged?.call(value);
          },
        ),
        widget.rightValue,
      ],
    );
  }
}
