import 'dart:io';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class SystemTrayManager with TrayListener {
  static final SystemTrayManager _instance = SystemTrayManager._internal();

  factory SystemTrayManager() {
    return _instance;
  }

  SystemTrayManager._internal();

  Future<void> init() async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/ic_launcher_linux.ico'
          : 'assets/images/app_icon_64.png',
    );
    await trayManager.setToolTip('NetShare');
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Window',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Quit',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
    trayManager.addListener(this);
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      windowManager.show();
      windowManager.focus();
    } else if (menuItem.key == 'exit_app') {
      windowManager.destroy();
    }
  }

  void dispose() {
    trayManager.removeListener(this);
  }
}
