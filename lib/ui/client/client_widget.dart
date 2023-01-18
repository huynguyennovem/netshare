import 'package:flutter/material.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/connection_status.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/ui/client/connect_widget.dart';
import 'package:netshare/ui/client/navigation_widget.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:provider/provider.dart';
import 'package:netshare/data/api_service.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/list_file/list_shared_files_widget.dart';

class ClientWidget extends StatefulWidget {
  const ClientWidget({super.key});

  @override
  State<ClientWidget> createState() => _ClientWidgetState();
}

class _ClientWidgetState extends State<ClientWidget> {
  @override
  void initState() {
    super.initState();
    // always fetch list files when first open Home screen
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final files = (await getIt.get<ApiService>().getSharedFiles()).getOrElse(() => {});
      if (mounted) {
        context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(builder: (BuildContext ct, value, Widget? child) {
      final connectionStatus = value.connectionStatus;
      final connectedIPAddress = value.connectedIPAddress;
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: connectionStatus == ConnectionStatus.connected
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    connectionStatus == ConnectionStatus.connected
                        ? const Icon(Icons.circle, size: 12.0, color: Colors.green)
                        : const Icon(Icons.circle, size: 12.0, color: Colors.grey),
                    const SizedBox(width: 6.0),
                    Text(
                      connectedIPAddress,
                      style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
                    ),
                  ],
                )
              : Text(
                  'NetShare',
                  style: CommonTextStyle.textStyleNormal.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                  ),
                ),
          leading: UtilityFunctions.isDesktop
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                )
              : null,
          actions: [
            connectionStatus == ConnectionStatus.connected
                ? IconButton(
                    onPressed: () {
                      context.read<ConnectionProvider>().disconnect();
                      context.read<FileProvider>().clearAllFiles();
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
            _buildConnectOptions(),
          ],
        ),
      );
    });
  }

  _buildConnectOptions() => Container(
    margin: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // FloatingActionButton.extended(
            //   heroTag: const Text("Scan"),
            //   onPressed: () => _onClickScanButton(),
            //   label: const Text('Scan to connect'),
            //   icon: const Icon(Icons.qr_code_scanner),
            // ),
            // const SizedBox(width: 20.0),
            FloatingActionButton.extended(
              heroTag: const Text("Manual"),
              onPressed: () => _onClickManualButton(),
              label: Text(
                'Manual connect',
                style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.black),
              ),
              icon: const Icon(Icons.account_tree),
            ),
          ],
        ),
  );

  // void _onClickScanButton() {
  //   context.go(Utilities.getRoutePath(name: mScanningWidget));
  // }

  void _onClickManualButton() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bsContext) {
        return ConnectWidget(onConnected: () async {
          Navigator.pop(context);

          // auto reload files
          final files = (await getIt.get<ApiService>().getSharedFiles()).getOrElse(() => {});
          if (mounted) {
          context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
          }
        });
      },
    );
  }
}
