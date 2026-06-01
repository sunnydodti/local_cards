import 'dart:async';
import 'package:flutter/material.dart';

typedef ScanCallback = FutureOr<bool> Function(String code);

class QRScannerWidget extends StatelessWidget {
  final ScanCallback onScanned;
  const QRScannerWidget({required this.onScanned, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController c = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text('Web build: camera scanner not available. Paste the payload below.'),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste encoded payload here',
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final text = c.text.trim();
              if (text.isNotEmpty) onScanned(text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
