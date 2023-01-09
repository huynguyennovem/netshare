import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/screen_navigation_mode.dart';
import 'package:netshare/ui/common_view/two_side_title_switch.dart';

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({Key? key}) : super(key: key);

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {

  ScreenNavigationMode _selectedMode = ScreenNavigationMode.server;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select mode:'),
                const SizedBox(width: 36.0),
                Flexible(
                  child: TwoSideTitleSwitch(
                    leftValue: const Text('CLIENT'),
                    rightValue: const Text('SERVER'),
                    switchInitValue: true,
                    onValueChanged: (value) {
                      _selectedMode = value ? ScreenNavigationMode.server : ScreenNavigationMode.client;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 56.0),
            FloatingActionButton.extended(
              onPressed: () => _onClickStart(),
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Start',
                  style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onClickStart() {
    switch(_selectedMode) {
      case ScreenNavigationMode.server:
        context.pushNamed(mServerPath);
        break;
      case ScreenNavigationMode.client:
        context.pushNamed(mClientPath);
        break;
    }
  }
}
