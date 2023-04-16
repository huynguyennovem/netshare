import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http_parser/http_parser.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/data/pref_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/function_mode.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/ui/common_view/address_field_widget.dart';
import 'package:netshare/ui/common_view/two_modes_switcher.dart';
import 'package:netshare/ui/server/qr_popup.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:mime/mime.dart';
import 'package:open_dir/open_dir.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;
import 'package:stop_watch_timer/stop_watch_timer.dart';

class ServerWidget extends StatefulWidget {
  const ServerWidget({Key? key}) : super(key: key);

  @override
  State<ServerWidget> createState() => _ServerWidgetState();
}

class _ServerWidgetState extends State<ServerWidget> {
  final _ipTextController = TextEditingController();
  final _portTextController = TextEditingController(text: '8080');

  final _fileDirectoryTextController = TextEditingController();
  final ValueNotifier<Directory> _pickedDir = ValueNotifier(Directory('/'));

  final ValueNotifier<bool> _isHostingNotifier = ValueNotifier(false);
  final ValueNotifier<HttpServer?> _serverNotifier = ValueNotifier(null);
  final _loggerController = TextEditingController();
  final ScrollController _loggerScrollBarController = ScrollController();
  final LogNotifier _logBuffer = LogNotifier(StringBuffer());

  late StopWatchTimer _stopWatchTimer;
  final ValueNotifier<String> _watchTimerValue = ValueNotifier('');

  late TwoModeSwitcher _twoModeSwitcher;
  final GlobalKey<TwoModeSwitcherState> _twoModeSwitcherKey = GlobalKey<TwoModeSwitcherState>();

  @override
  void initState() {
    super.initState();

    // pre-loading values
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final lastAddress = await getIt.get<PrefData>().getLastHostedAddress();
      if (lastAddress != null && lastAddress.isNotEmpty) {
        final addresses = lastAddress.split(':');
        _ipTextController.text = addresses[0];
        _portTextController.text = addresses[1];
      } else {
        // get current IP if there is no saved address
        final deviceIP = await UtilityFunctions.getIPAddress();
        if (deviceIP != null && deviceIP.isNotEmpty) {
          _ipTextController.text = deviceIP;
        }
      }
      final lastSavedDir = await getIt.get<PrefData>().getLastPickedPathDir();
      if (lastSavedDir != null && lastSavedDir.isNotEmpty) {
        _fileDirectoryTextController.text = lastSavedDir;
        _pickedDir.value = Directory(lastSavedDir);
      }
    });

    // logger
    _loggerController.addListener(() {
      _loggerScrollBarController.animateTo(
        _loggerScrollBarController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });

    // server uptime
    _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
    _stopWatchTimer.secondTime.listen((secs) {
      _watchTimerValue.value = Duration(seconds: secs).formatTime();
    });
    _isHostingNotifier.addListener(() async {
      if(_isHostingNotifier.value) {
        _stopWatchTimer.onStartTimer();
      } else {
        _stopWatchTimer.onResetTimer();
      }
    });

    // mode switcher
    _twoModeSwitcher = TwoModeSwitcher(
      key: _twoModeSwitcherKey,
      switchInitValue: true,
      onValueChanged: (mode) => context.switchingModes(
        newMode: mode == true ? FunctionMode.server : FunctionMode.client,
        confirmCallback: (isUserAgreed) {
          if(isUserAgreed) {
            _stopHosting(isForce: true);
            // force using goNamed instead of pushName, due to:
            // Client and Server widget are sibling widgets, not descendants
            // Need replacing to target route, not adding
            context.goNamed(mClientPath);
          } else {
            _twoModeSwitcherKey.currentState?.updateExternalValue(true);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _disposeAllThings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: _twoModeSwitcher,
        actions: [
          _buildAppBarActions()
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: ValueListenableBuilder(
            valueListenable: _isHostingNotifier,
            builder: (BuildContext context, bool isServerStarted, Widget? child) {
              return Column(
                children: [
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: Column(
                      children: [
                        _buildIPPortRow(isServerStarted),
                        const SizedBox(height: 8.0),
                        _buildDirPickerRow(isServerStarted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  _buildStartHostingButton(isServerStarted),
                  const SizedBox(height: 28.0),
                  Expanded(
                    child: _buildLogOutput(isServerStarted),
                  ),
                ],
              );
            }),
      ),
    );
  }

  _buildAppBarActions() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ValueListenableBuilder(
      valueListenable: _isHostingNotifier,
      builder: (BuildContext context, bool value, Widget? child) {
        return value ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 12.0, color: Colors.red),
            const SizedBox(width: 8.0),
            ValueListenableBuilder(
              valueListenable: _watchTimerValue,
              builder: (BuildContext context, String value, Widget? child) {
                return Text(
                  value.isEmpty ? '00:00:00' : value,
                  style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
                );
              },
            ),
            const SizedBox(width: 16.0),
            QRMenuPopup(ipAddress: _ipTextController.text, port: _portTextController.text),
          ],
        ) : const SizedBox.shrink();
      },
    ),
  );

  _buildIPPortRow(isServerStarted) => Row(
    children: [
      Expanded(
        child: AddressFieldWidget(
          ipTextController: _ipTextController,
          portTextController: _portTextController,
          isEnableIP: !isServerStarted,
          isEnablePort: !isServerStarted,
        ),
      ),
      UtilityFunctions.isDesktop ? const SizedBox(width: 80.0) : const SizedBox(width: 8.0),
    ],
  );

  _buildDirPickerRow(isServerStarted) => IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                enabled: !isServerStarted,
                controller: _fileDirectoryTextController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Pick the sharing path here',
                  hintStyle: const TextStyle(color: Colors.black26),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12.withOpacity(0.2), width: 1.2),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12.withOpacity(0.2), width: 1.2),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            SizedBox(
              width: 72.0,
              child: MaterialButton(
                elevation: !isServerStarted ? 4.0 : 0.0,
                height: double.infinity,
                color: !isServerStarted
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onPressed: () => !isServerStarted ? _onClickSelectDirPath() : null,
                child: const SizedBox(
                  child: Icon(
                    Icons.drive_folder_upload,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            UtilityFunctions.isDesktop
                ? SizedBox(
                    width: 72,
                    child: MaterialButton(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: () => _openNativeDirectory(_fileDirectoryTextController.text),
                      child: const SizedBox(
                        child: Icon(
                          Icons.open_in_new,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      );

  _buildStartHostingButton(isServerStarted) => FloatingActionButton.extended(
        backgroundColor: isServerStarted ? Colors.redAccent : Colors.blueAccent,
        onPressed: () => _onClickStart(
          ipAddress: _ipTextController.text,
          port: int.parse(_portTextController.text),
        ),
        icon: const Icon(Icons.wifi_tethering, color: Colors.white),
        label: Text(
          isServerStarted ? 'Stop hosting' : 'Start hosting',
          style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
        ),
      );

  _buildLogOutput(isServerStarted) => ValueListenableBuilder(
        valueListenable: _logBuffer,
        builder: (BuildContext context, StringBuffer value, Widget? child) {
          _loggerController.text = value.toString();
          return TextField(
            maxLines: null,
            expands: true,
            readOnly: true,
            scrollController: _loggerScrollBarController,
            controller: _loggerController,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(color: Colors.white, fontSize: 12.0),
            decoration: const InputDecoration(
              fillColor: Colors.black87,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
            ),
          );
        },
      );

  _onClickSelectDirPath() async {
    try {
      final isOldDirExisted = await _pickedDir.value.exists();
      if(isOldDirExisted) {
        String? result = await FilePicker.platform.getDirectoryPath(
          initialDirectory: _pickedDir.value.path,
        );
        if (result != null && result.isNotEmpty) {
          _fileDirectoryTextController.text = result;
          _pickedDir.value = Directory(result);
          getIt.get<PrefData>().saveLastPickedPathDir(result);
        }
      } else {
        // when old picked path does not exist anymore (may be deleted after the first pick)
        _pickedDir.value = Directory('/');
        _onClickSelectDirPath();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _onClickStart({required String ipAddress, required int port}) async {
    // dismissing keyboard while connecting
    FocusScope.of(context).unfocus();

    if (!_isHostingNotifier.value) {
      _startHosting(ipAddress, port);
    } else {
      _stopHosting(isForce: true);
    }
  }

  _staticHandler(String pathDir) => shelf_static.createStaticHandler(pathDir);

  Response _undefinedHandler(Request request) => Response.notFound('Request is not found!');

  void _startHosting(ipAddress, port) async {
    final address = '$ipAddress:$port';
    final dir = Directory(_fileDirectoryTextController.text);
    if(!dir.existsSync()) {
      context.showSnackbar('Sharing path does not exist. Try again!');
      return;
    }

    // Router instance to handler requests.
    // Use shelf_router.Router(notFoundHandler: _staticHandler(dir.path))
    // as a fallback for static handler (may use this later)
    final routerHandler = shelf_router.Router()
      ..get('/files', (request) => _getFilesHandler(request, address))
      ..post('/upload', (request) => _uploadFileHandler(request, address));

    // static handler always in the first order in list handlers
    Cascade cascade = Cascade()
          .add(_staticHandler(dir.path))
          .add(routerHandler)
          .add(_undefinedHandler);
    var handler = const Pipeline()
        .addMiddleware(logRequests(logger: (message, isError) => _exposeLogger(message: message)))
        .addHandler(cascade.handler);

    _isHostingNotifier.value = !_isHostingNotifier.value;

    try {
      _serverNotifier.value = await shelf_io.serve(handler, ipAddress, port).catchError((error) {
        if (mounted) {
          context.showSnackbar('Failed to host a server! Try again later!');
        }
        throw error;
      });

      getIt.get<PrefData>().saveLastHostedAddress(address);
      _exposeLogger(message: 'Start server at http://${_serverNotifier.value?.address.host}:${_serverNotifier.value?.port}');

    } catch (e) {
      debugPrint(e.toString());
      _stopHosting(isForce: false);
    }
  }

  void _stopHosting({required isForce}) {
    _exposeLogger(message: 'Stop server...');
    _isHostingNotifier.value = !_isHostingNotifier.value;
    _serverNotifier.value?.close(force: isForce);
  }

  Future<Response> _getFilesHandler(Request request, String address) async {
    // TODO: Blocking by https://github.com/dart-lang/sdk/issues/40303
    // (Hidden files are included)
    List<FileSystemEntity> files = await _pickedDir.value.list().where((f) {
      final fileName = path.basename(f.path);
      if (!fileName.startsWith('.')) return true;
      return false;
    }).toList();

    final listJson = files.map((f) {
      final fileName = path.basename(f.path);
      return SharedFile(name: fileName, url: 'http://$address/$fileName').toJson();
    }).toList();
    return Response(
      HttpStatus.ok,
      headers: {'content-type': 'application/json'},
      body: json.encode(listJson),
    );
  }

  Future<Response> _uploadFileHandler(Request request, String address) async {
    final contentType = MediaType.parse(request.headers['Content-Type'] ?? '');
    final transformer = MimeMultipartTransformer(contentType.parameters["boundary"] ?? '');
    final parts = transformer.bind(request.read());
    try {
      List<String> listFileName = [];
      await for (final part in parts) {
        final content = part.cast<List<int>>();

        // parse file name from header
        List<String> pairs = part.headers['content-disposition']?.split(";") ?? [];
        final fileName = pairs.map((element) {
          if(element.contains('filename')) {
            return element.substring(element.indexOf("=") + 2, element.length - 1);
          }
          return '';
        }).firstWhere((element) => element.isNotEmpty);
        listFileName.add(fileName);

        // save file to storage
        final filePath = "${_pickedDir.value.path}/$fileName";
        IOSink sink = File(filePath).openWrite();
        await for (List<int> item in content) {
          sink.add(item);
        }
        await sink.flush();
        await sink.close();
      }

      // response added files
      final listJson = listFileName.map((fileName) {
        return SharedFile(name: fileName, url: 'http://$address/$fileName').toJson();
      }).toList();
      return Response(
        HttpStatus.ok,
        headers: {'content-type': 'application/json'},
        body: json.encode(listJson),
      );
    } catch (e) {
      debugPrint(e.toString());
      return Response(HttpStatus.badRequest);
    }
  }

  _exposeLogger({required String message}) {
    debugPrint(message);
    _logBuffer.appendLog(message: message);
  }

  _disposeAllThings() {
    _stopHosting(isForce: true);

    _ipTextController.dispose();
    _portTextController.dispose();
    _fileDirectoryTextController.dispose();
    _pickedDir.dispose();

    _loggerController.dispose();
    _loggerScrollBarController.dispose();
    _logBuffer.dispose();

    _isHostingNotifier.dispose();
    _serverNotifier.dispose();

    _watchTimerValue.dispose();
    _stopWatchTimer.dispose();

    debugPrint('Disconnected Server!');
  }

  _openNativeDirectory(String path) async {
    try {
      final openDirPlugin = OpenDir();
      final rs = await openDirPlugin.openNativeDir(path: path);
      if(rs != null && rs) {
        debugPrint('Opened directory: $path');
      } else {
        if (mounted) {
          context.showSnackbar('Sharing directory is not found!');
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to open native directory: ${e.message}');
    }
  }
}

// This class is to fix the error of not updating the UI when updating the StringBuffer's value.
class LogNotifier extends ValueNotifier<StringBuffer> {
  LogNotifier(super.value);

  void appendLog({required String message}) {
    value.writeln(message);
    notifyListeners();
  }
}
