import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

const double qrSize = 148.0;

class QRMenuPopup extends StatefulWidget {
  final String ipAddress;
  final String port;

  const QRMenuPopup({
    Key? key,
    required this.ipAddress,
    required this.port,
  }) : super(key: key);

  @override
  State<QRMenuPopup> createState() => _QRMenuPopupState();
}

class _QRMenuPopupState extends State<QRMenuPopup> with SingleTickerProviderStateMixin {
  OverlayEntry? overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void dispose() {
    removeHighlightOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: const [
            BoxShadow(
              blurStyle: BlurStyle.outer,
              blurRadius: 8.0,
              color: Colors.black26,
            ),
          ]
      ),
      child: IconButton(
        key: _buttonKey,
        onPressed: () => _onClickQRCode(),
        padding: EdgeInsets.zero,
        iconSize: 24.0,
        icon: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(Icons.qr_code, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  _onClickQRCode() {
    _createHighlightOverlay();
  }

  void _createHighlightOverlay() {
    removeHighlightOverlay();
    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: removeHighlightOverlay,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final RenderBox buttonRenderBox =
                _buttonKey.currentContext?.findRenderObject() as RenderBox;
            final buttonSize = buttonRenderBox.size;
            final buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);
            return Stack(
              children: [
                Positioned(
                  top: buttonPosition.dy + buttonSize.height * 1.5,
                  left: buttonPosition.dx - qrSize + buttonSize.height * 2.0,
                  child: SizedBox(
                    width: qrSize,
                    height: qrSize,
                    child: Container(
                      decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          shadows: const [
                            BoxShadow(
                              offset: Offset(1.5, 2.5),
                              blurStyle: BlurStyle.outer,
                              blurRadius: 8.0,
                              color: Colors.black26,
                            ),
                          ]),
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        child: QrImageView(
                          data: "${widget.ipAddress}:${widget.port}",
                          version: QrVersions.auto,
                          gapless: false,
                          semanticsLabel: 'Generated QR Code. Scan to connect',
                        ),
                      ),
                      // Container(color: Colors.red,)
                    ),
                  ),
                )
              ],
            );
          },
        ),
      );
    });

    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  void removeHighlightOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}
