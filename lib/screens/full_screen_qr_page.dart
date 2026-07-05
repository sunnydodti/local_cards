import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class FullScreenQrPage extends StatelessWidget {
  final String encrypted;
  const FullScreenQrPage({super.key, required this.encrypted});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final double qrSize = math.min(media.width, media.height) * 0.95;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: encrypted));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payload copied to clipboard')),
              );
            },
            tooltip: 'Copy raw text',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: qrSize,
                      height: qrSize,
                      child: QrImageView(
                        data: encrypted,
                        version: QrVersions.auto,
                        size: qrSize,
                        gapless: false,
                      ),
                    ),
                  ),
                ),
              ),
              ExpansionTile(
                title: const Text('Show raw encrypted payload'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(
                      encrypted,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
