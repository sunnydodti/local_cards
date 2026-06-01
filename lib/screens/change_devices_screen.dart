import 'package:flutter/material.dart';
import '../widgets/my_appbar.dart';
import '../widgets/mobile_wrapper.dart';
import 'transfer_screen.dart';
import 'receive_screen.dart';

class ChangeDevicesScreen extends StatelessWidget {
  const ChangeDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(context, title: 'Change Devices', back: true),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Transfer'),
                  subtitle: const Text('Encrypt and share your data via QR'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TransferScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Receive'),
                  subtitle: const Text('Scan a QR to import data'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Transfer data securely between devices',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
