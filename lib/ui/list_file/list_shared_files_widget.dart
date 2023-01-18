import 'package:flutter/material.dart';
import 'package:netshare/data/api_service.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/source_screen.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/common_view/empty_widget.dart';
import 'package:netshare/ui/list_file/file_tile.dart';
import 'package:provider/provider.dart';

class ListSharedFiles extends StatefulWidget {
  const ListSharedFiles({super.key});

  @override
  State<ListSharedFiles> createState() => _ListSharedFilesState();
}

class _ListSharedFilesState extends State<ListSharedFiles> {

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(
      builder: (context, value, child) {
        final files = value.files;
        debugPrint('Fetched files: ${files.length}');
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              _buildHeader(),
              Flexible(
                child: files.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return FileTile(
                            sharedFile: files.elementAt(index),
                            sourceScreen: SourceScreen.client,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            color: Colors.black12,
                            height: 0.5,
                            indent: 8.0,
                            endIndent: 8.0,
                          );
                        },
                        itemCount: files.length,
                      )
                    : const EmptyWidget(),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      const Text('Recent files'),
      TextButton(
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
          child: const Icon(Icons.sync, color: Colors.white),
        ),
        onPressed: () async {
          final files = (await getIt.get<ApiService>().getSharedFiles()).getOrElse(() => {});
          if (mounted) {
            context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
          }
        },
      ),
    ],
  );
}
