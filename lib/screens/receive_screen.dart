import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../service/card_service.dart';
import '../services/transfer_service.dart';
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
              children: [
                Text(
                  'Scan or paste the transfer payload',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: QRScannerWidget(onScanned: _handleScanned),
                      ),
                    ),
                  ),
                ),
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
}

class _PasswordDialog extends StatelessWidget {
  const _PasswordDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    return AlertDialog(
      title: const Text('Enter password'),
      content: TextField(
        controller: _controller,
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
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
