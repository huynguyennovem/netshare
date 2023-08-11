import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/repository/file_repository.dart';
import 'package:netshare/service/download_service.dart';
import 'package:netshare/data/hivedb/clients/shared_file_client.dart';
import 'package:netshare/entity/connection_status.dart';
import 'package:netshare/entity/download/download_entity.dart';
import 'package:netshare/entity/download/download_manner.dart';
import 'package:netshare/entity/download/download_state.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/ui/client/connect_widget.dart';
import 'package:netshare/ui/client/navigation_widget.dart';
import 'package:netshare/ui/common_view/two_modes_switcher.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:provider/provider.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/list_file/list_shared_files_widget.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/entity/function_mode.dart';

class ClientWidget extends StatefulWidget {
  const ClientWidget({super.key});

  @override
  State<ClientWidget> createState() => _ClientWidgetState();
}

class _ClientWidgetState extends State<ClientWidget> {

  final ReceivePort _port = ReceivePort();
  final fileRepository = getIt.get<FileRepository>();

  late TwoModeSwitcher _twoModeSwitcher;
  final GlobalKey<TwoModeSwitcherState> _twoModeSwitcherKey = GlobalKey<TwoModeSwitcherState>();

  @override
  void initState() {
    super.initState();
    // always fetch list files when first open Home screen
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final files = (await fileRepository.getSharedFilesWithState()).getOrElse(() => {});
      if (mounted) {
        context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
      }
    });
    _initDownloadModule();
    _downloadStreamListener();
    _initSwitcher();
  }

  void _initDownloadModule() {
    if (UtilityFunctions.isMobile) {
      try {
        IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
        _port.listen((dynamic data) async {

          // TODO: 2. Flutter engine issue: can only send basic dart type
          // convert int to a custom state
          DownloadState state = (data[1] as int).toDownloadState;

          // only update state when finished, less update, less memory usage
          if(DownloadState.downloading != state) {
            String taskId = data[0];
            final tasks = await FlutterDownloader.loadTasksWithRawQuery(
              query: "SELECT * FROM task WHERE task_id = \"$taskId\"",
            );
            String? fileName;
            String? url;
            String? savedDir;
            if (null != tasks && tasks.isNotEmpty) {
              final task = tasks.firstWhere((element) => taskId == element.taskId);
              fileName = task.filename;
              url = task.url;
              savedDir = task.savedDir;
              getIt.get<DownloadService>().updateDownloadState(
                  DownloadEntity(
                    taskId,
                    fileName ?? '',
                    url,
                    savedDir,
                    DownloadManner.flutterDownloader,
                    state,
                  )
              );
            }
          }
        });
        FlutterDownloader.registerCallback(downloadCallback);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void _downloadStreamListener() {
    getIt.get<DownloadService>().downloadStream.listen((downloadEntity) {
      debugPrint("[DownloadService] Download stream log: $downloadEntity");

      // update state to the list files
      if (mounted) {
        context.read<FileProvider>().updateFile(
          fileName: downloadEntity.fileName,
          newFileState: downloadEntity.state.toSharedFileState,
          savedDir: downloadEntity.savedDir,
        );
      }

      // add succeed file to Hive database
      if (downloadEntity.state == DownloadState.succeed) {
        getIt.get<SharedFileClient>().add(
              SharedFile(
                name: downloadEntity.fileName,
                url: downloadEntity.url,
                savedDir: downloadEntity.savedDir,
                state: DownloadState.succeed.toSharedFileState,
              ),
            );
      }
    });
  }

  void _initSwitcher() {
    _twoModeSwitcher = TwoModeSwitcher(
      key: _twoModeSwitcherKey,
      switchInitValue: false,
      onValueChanged: (mode) => context.switchingModes(
        newMode: mode == true ? FunctionMode.server : FunctionMode.client,
        confirmCallback: (isUserAgreed) {
          if(isUserAgreed) {
            _disconnect();
            // force using goNamed instead of pushName, due to:
            // Client and Server widget are sibling widgets, not descendants
            // Need replacing to target route, not adding
            context.goNamed(mServerPath);
          } else {
            _twoModeSwitcherKey.currentState?.updateExternalValue(false);
          }
        },
      ),
    );
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    debugPrint(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );
    // TODO: 1. Flutter engine issue: can only send basic dart type + restart/hot reload does not work
    //  (https://github.com/flutter/flutter/issues/119589)
    //  can only send basic dart type -> Fix: convert status entity to int
    IsolateNameServer.lookupPortByName('downloader_send_port')?.send([id, status, progress]);
  }

  @override
  void dispose() {
    if (UtilityFunctions.isMobile) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
    }
    debugPrint('Disconnected Client!');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(builder: (BuildContext ct, value, Widget? child) {
      final connectionStatus = value.connectionStatus;
      final connectedIPAddress = value.connectedIPAddress;
      final isConnected = connectionStatus == ConnectionStatus.connected;
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: !Platform.isIOS ? _twoModeSwitcher : const SizedBox.shrink(),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                isConnected
                    ? const Icon(Icons.circle, size: 12.0, color: Colors.green)
                    : const Icon(Icons.circle, size: 12.0, color: Colors.grey),
                const SizedBox(width: 6.0),
                Text(
                  connectedIPAddress,
                  style: CommonTextStyle.textStyleNormal.copyWith(color: textIconButtonColor),
                ),
              ],
            ),
            isConnected
                ? IconButton(
                    onPressed: () {
                      _disconnect();
                    },
                    icon: const Icon(Icons.link_off),
                  )
                : IconButton(
                    onPressed: () => _onClickManualButton(),
                    icon: const Icon(Icons.link),
                  ),
          ],
        ),
        body: Column(
          children: [
            NavigationWidgets(connectionStatus: connectionStatus),
            const Expanded(child: ListSharedFiles()),
            isConnected ? const SizedBox.shrink() : _buildConnectOptions(),
          ],
        ),
      );
    });
  }

  _buildConnectOptions() => Container(
    margin: const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UtilityFunctions.isMobile
                ? Row(
                    children: [
                      FloatingActionButton.extended(
                        heroTag: const Text("Scan"),
                        onPressed: () => _onClickScanButton(),
                        label: Text(
                          'Scan to connect',
                          style: CommonTextStyle.textStyleNormal.copyWith(
                            color: textIconButtonColor,
                            fontSize: 14.0,
                          ),
                        ),
                        icon: const Icon(Icons.qr_code_scanner, color: textIconButtonColor),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                  )
                : const SizedBox.shrink(),
            Flexible(
              child: FloatingActionButton.extended(
                heroTag: const Text("Manual"),
                onPressed: () => _onClickManualButton(),
                label: Text(
                  'Manual connect',
                  style: CommonTextStyle.textStyleNormal.copyWith(
                    color: textIconButtonColor,
                    fontSize: 14.0,
                  ),
                ),
                icon: const Icon(Icons.account_tree, color: textIconButtonColor),
              ),
            ),
          ],
        ),
  );

  _onClickScanButton() async {
    final isPermissionGranted = await UtilityFunctions.checkCameraPermission(
      onPermanentlyDenied: () => context.showOpenSettingsDialog(),
    );
    if(isPermissionGranted) {
      if(mounted) {
        final result = await context.pushNamed<bool>(mScanningPath);
        if(result == true) {
          _syncFiles();
        }
      }
    } else {
      if (mounted) {
        context.showSnackbar('Need Camera permission to continue');
      }
    }
  }

  _onClickManualButton() {
    if(UtilityFunctions.isDesktop) {
      showDialog(
        context: context,
        builder: (bsContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 2,
                maxHeight: MediaQuery.of(context).size.height / 2,
              ),
              child: ConnectWidget(onConnected: () async {
                Navigator.pop(context);
                _syncFiles();
              }),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (bsContext) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ConnectWidget(onConnected: () async {
              Navigator.pop(context);
              _syncFiles();
            }),
          );
        },
      );
    }
  }

  _disconnect() {
    context.read<ConnectionProvider>().disconnect();
    context.read<FileProvider>().clearAllFiles();
  }

  _syncFiles() async {
    final files = (await fileRepository.getSharedFilesWithState()).getOrElse(() => {});
    if (mounted) {
    context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
    }
  }
}
