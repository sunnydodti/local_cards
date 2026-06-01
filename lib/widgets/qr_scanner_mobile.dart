import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef ScanCallback = FutureOr<bool> Function(String code);

class QRScannerWidget extends StatefulWidget {
  final ScanCallback onScanned;
  const QRScannerWidget({required this.onScanned, super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final MobileScannerController controller = MobileScannerController();
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: (capture) {
        if (_scanned) return;
        final barcodes = capture.barcodes;
        if (barcodes.isEmpty) return;
        final code = barcodes.first.rawValue;
        if (code != null) {
          _scanned = true;
          // Use Future.delayed(Duration.zero) to escape the platform channel message loop.
          // This avoids the '_dependents.isEmpty': is not true assertion error when showing dialogs.
          Future.delayed(Duration.zero, () async {
            final success = await widget.onScanned(code);
            if (!success && mounted) {
              setState(() {
                _scanned = false;
              });
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
