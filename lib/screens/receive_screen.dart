import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../service/card_service.dart';
import '../services/transfer_service.dart';
import 'package:provider/provider.dart';
import '../data/provider/card_provider.dart';
import '../widgets/mobile_wrapper.dart';
import '../widgets/my_appbar.dart';
import '../widgets/qr_scanner.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  bool _handledScan = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(context, title: 'Receive', back: true),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                  'Scan or paste the transfer payload',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Button to paste a Base64 string as an alternative to scanning
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _pasteBase64,
                    child: const Text('Paste Base64'),
                  ),
                ),
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: QRScannerWidget(onScanned: _handleScanned),
                ),
                // Helper method for pasting a Base64 payload
                // (implemented later in the file)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _handleScanned(String code) async {
    if (_handledScan) return false;
    _handledScan = true;
    try {
      final decoded = utf8.decode(base64Decode(code));
      final Map<String, dynamic> envelope = jsonDecode(decoded);
      if (envelope['enc'] != true) {
        _showMessage('Scanned data is not a valid transfer payload');
        return false;
      }
      final password = await _askForPassword();
      if (password == null || password.isEmpty) {
        _showMessage('Password required');
        return false;
      }
      final payload = TransferService.decryptPayload(code, password);
      await _importPayload(payload);
      _showMessage('Data imported');
      context.read<CardProvider>().load();
      return true;
    } catch (_) {
      _showMessage('Invalid or unsupported QR data');
      return false;
    } finally {
      _handledScan = false;
    }
  }

  Future<String?> _askForPassword() async {
    return showDialog<String?>(
      context: context,
      builder: (dialogContext) => const _PasswordDialog(),
    );
  }

  Future<void> _importPayload(Map<String, dynamic> payload) async {
    final cards = payload['cards'];
    if (cards is! List) return;
    for (final dynamic item in cards) {
      try {
        final map = Map<String, dynamic>.from(item as Map);
        final card = CardModel.fromMap(map);
        await CardService.instance().createCard(card);
      } catch (_) {
        continue;
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  //  Paste‑Base64 dialog
  // ---------------------------------------------------------------------------
  Future<void> _pasteBase64() async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Paste Base64 payload'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Enter the Base64 string here',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      // Re‑use the same handling logic as a scanned QR code.
      await _handleScanned(result);
    }
  }

}

class _PasswordDialog extends StatelessWidget {
  const _PasswordDialog();

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return AlertDialog(
      title: const Text('Enter password'),
      content: TextField(
        controller: controller,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
