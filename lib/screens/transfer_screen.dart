import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/my_appbar.dart';
import '../widgets/mobile_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../services/security_service.dart';
import '../service/card_service.dart';
import '../services/transfer_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.clear();
    _passwordController.dispose();
    super.dispose();
  }

  void _onNext() async {
    // TODO: verify device auth, encrypt data, show QR
    final password = _passwordController.text;
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password')),
      );
      return;
    }

    // Require device authentication via SecurityService
    final security = Provider.of<SecurityService>(context, listen: false);
    final ok = await security.authenticateIfNeeded();
    if (!ok) return;

    // Collect data from CardService
    final cards = await CardService.instance().listCards();
    final payload = {
      'cards': cards.map((c) => c.toMap()).toList(),
      'generatedAt': DateTime.now().toIso8601String(),
    };

    final encrypted = TransferService.encryptPayload(payload, password);

    // Show QR in a dialog
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan this QR code from your new device to transfer your data securely.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: encrypted,
                  version: QrVersions.auto,
                  size: 240.0,
                  gapless: false,
                ),
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text(
                  'Show raw encrypted payload',
                  style: TextStyle(fontSize: 12),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SelectableText(
                      encrypted,
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: encrypted));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payload copied to clipboard')),
              );
            },
            child: const Text('Copy Raw Text'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    // Clear one-time password from memory
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(context, title: 'Transfer', back: true),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter a one-time password to encrypt your data',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon:
                        Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.lock),
                label: const Text('Encrypt & Show QR'),
                onPressed: _onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
