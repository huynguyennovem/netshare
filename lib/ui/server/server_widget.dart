import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/data/pref_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/ui/common_view/address_field_widget.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

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
  final ValueNotifier<StringBuffer> _logBuffer = ValueNotifier(StringBuffer());

  @override
  void initState() {
    super.initState();
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
    _loggerController.addListener(() {
      _loggerScrollBarController.animateTo(
        _loggerScrollBarController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: ValueListenableBuilder(
            valueListenable: _isHostingNotifier,
            builder: (BuildContext context, bool value, Widget? child) {
              return Column(
                children: [
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 2 / 3,
                    child: Column(
                      children: [
                        _buildIPPortRow(value),
                        const SizedBox(height: 8.0),
                        _buildDirPickerRow(value),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  _buildStartHostingButton(value),
                  const SizedBox(height: 28.0),
                  Expanded(
                    child: _buildLogOutput(value),
                  ),
                ],
              );
            }),
      ),
    );
  }

  _buildIPPortRow(value) => AddressFieldWidget(
    ipTextController: _ipTextController,
    portTextController: _portTextController,
    isEnableIP: !value,
    isEnablePort: !value,
  );

  _buildDirPickerRow(value) => IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                enabled: !value,
                controller: _fileDirectoryTextController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: '/Users/username/directory',
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
              child: MaterialButton(
                elevation: !value ? 4.0 : 0.0,
                height: double.infinity,
                color: !value
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onPressed: () => !value ? _onClickSelectDirPath() : null,
                child: const SizedBox(
                  child: Icon(
                    Icons.drive_folder_upload,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  _buildStartHostingButton(value) => FloatingActionButton.extended(
        backgroundColor: value ? Colors.redAccent : Colors.blueAccent,
        onPressed: () => _onClickStart(
          ipAddress: _ipTextController.text,
          port: int.parse(_portTextController.text),
        ),
        icon: const Icon(Icons.wifi_tethering, color: Colors.white),
        label: Text(
          value ? 'Stop hosting' : 'Start hosting',
          style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
        ),
      );

  _buildLogOutput(value) => ValueListenableBuilder(
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

    // Router instance to handler requests.
    // Use shelf_router.Router(notFoundHandler: _staticHandler(_pickedDir.value.path))
    // as a fallback for static handler (may use this later)
    final routerHandler = shelf_router.Router()
      ..get('/files', (request) => _getFilesHandler(request, address))
      ..post('/upload', (request) => _uploadFileHandler(request, address));

    // static handler always in the first order in list handlers
    Cascade cascade;
    if (_pickedDir.value.existsSync()) {
      cascade = Cascade()
          .add(_staticHandler(_pickedDir.value.path))
          .add(routerHandler)
          .add(_undefinedHandler);
    } else {
      cascade = Cascade()
          .add(routerHandler)
          .add(_undefinedHandler);
    }
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
    _logBuffer.value.writeln(message);
    _logBuffer.notifyListeners();
  }
}
