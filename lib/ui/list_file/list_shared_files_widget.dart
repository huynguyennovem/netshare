import 'package:flutter/material.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/repository/file_repository.dart';
import 'package:netshare/ui/common_view/empty_widget.dart';
import 'package:netshare/ui/list_file/file_tile_client.dart';
import 'package:provider/provider.dart';

class ListSharedFiles extends StatefulWidget {
  const ListSharedFiles({super.key});

  @override
  State<ListSharedFiles> createState() => _ListSharedFilesState();
}

class _ListSharedFilesState extends State<ListSharedFiles> {

  final fileRepository = getIt.get<FileRepository>();
  final scrollController = ScrollController();

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
              files.isNotEmpty ? _buildHeader() : const SizedBox.shrink(),
              const SizedBox(height: 8.0),
              Flexible(
                child: files.isNotEmpty
                    ? _buildListFiles(files)
                    : const EmptyWidget(message: 'No file found'),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildListFiles(files) => Container(
    margin: const EdgeInsets.all(16.0),
    child: Scrollbar(
      controller: scrollController,
      thumbVisibility: false,
      child: ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return FileTileClient(sharedFile: files.elementAt(index));
        },
        separatorBuilder: (context, index) {
          return const Divider(
            color: Colors.black12,
            height: 0.5,
            indent: 8.0,
            endIndent: 8.0,
            thickness: 0.6,
          );
        },
        itemCount: files.length,
      ),
    ),
  );

  _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      const Text('Recent files'),
      Container(
        width: 36.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            onPressed: () async {
              final files =
                  (await fileRepository.getSharedFilesWithState()).getOrElse(() => {});
              if (mounted) {
                context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
              }
            },
            child: const Icon(Icons.sync, color: Colors.white, size: 20.0),
          ),
        ),
      ),
    ],
  );
}
