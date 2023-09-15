import 'package:flutter/widgets.dart';
import 'package:netshare/entity/function_mode.dart';

class AppProvider extends ChangeNotifier {
  FunctionMode _appMode = FunctionMode.none;
  FunctionMode get appMode => _appMode;

  void updateAppMode({required FunctionMode appMode}) {
    _appMode = appMode;
    notifyListeners();
  }
}