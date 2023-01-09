import 'package:flutter/material.dart';
import 'package:netshare/config/styles.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No data',
        style: CommonTextStyle.textStyleNormal,
      ),
    );
  }
}
