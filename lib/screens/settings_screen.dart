import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/provider/card_provider.dart';
import '../widgets/my_appbar.dart';
import '../widgets/mobile_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/security_service.dart';
import 'change_devices_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(context, title: 'Settings', back: true),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Security Toggle
                Consumer<SecurityService>(
                  builder: (context, securityService, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'App Lock (Fingerprint/Device Lock)',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Switch(
                            value: securityService.lockEnabled,
                            onChanged: (val) =>
                                securityService.setLockEnabled(val),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    size: 64,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                // App Name
                Text(
                  'Local Cards',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Securely store and manage your cards',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Card Detail Toggles
                Consumer<CardProvider>(
                  builder: (context, cardProvider, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Defaults',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Show Card Number'),
                            value: cardProvider.showNumber,
                            onChanged: (val) => cardProvider.setShowNumber(val),
                          ),
                          SwitchListTile(
                            title: const Text('Show Expiry'),
                            value: cardProvider.showExpiry,
                            onChanged: (val) => cardProvider.setShowExpiry(val),
                          ),
                          SwitchListTile(
                            title: const Text('Show CVV'),
                            value: cardProvider.showCVV,
                            onChanged: (val) => cardProvider.setShowCVV(val),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Project Links
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Links',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text('Source Code'),
                          subtitle:
                              const Text('github.com/sunnydodti/local_cards'),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () => _launchUrl(
                              'https://github.com/sunnydodti/local_cards'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.download),
                          title: const Text('Download'),
                          subtitle: const Text('Latest Release'),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () => _launchUrl(
                              'https://github.com/sunnydodti/local_cards/releases/latest'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text('All Releases'),
                          subtitle: const Text('View Release History'),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () => _launchUrl(
                              'https://github.com/sunnydodti/local_cards/releases'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Developer Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: const Text(
                            'Sunny Dodti',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Software Developer'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.location_on, size: 20),
                          title: const Text('Mumbai, India'),
                          dense: true,
                        ),
                        ListTile(
                          leading: const Icon(Icons.email, size: 20),
                          title: const Text('sunnydodti.dev@gmail.com'),
                          trailing: const Icon(Icons.open_in_new, size: 16),
                          dense: true,
                          onTap: () =>
                              _launchUrl('mailto:sunnydodti.dev@gmail.com'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Social Links
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('Portfolio'),
                          subtitle: const Text('sunny.persist.site'),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () => _launchUrl('https://sunny.persist.site'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text('GitHub'),
                          subtitle: const Text('github.com/sunnydodti'),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () =>
                              _launchUrl('https://github.com/sunnydodti'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.business),
                          title: const Text('LinkedIn'),
                          subtitle: const Text('linkedin.com/in/sunnydodti'),
                          trailing: const Icon(Icons.open_in_new, size: 20),
                          onTap: () => _launchUrl(
                              'https://www.linkedin.com/in/sunnydodti'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Features
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          Icons.credit_card,
                          'Card Storage',
                          'Securely store your card details with encryption',
                        ),
                        _buildFeatureItem(
                          Icons.visibility,
                          'Visibility Toggles',
                          'Control which card details are shown by default',
                        ),
                        _buildFeatureItem(
                          Icons.copy,
                          'Copy to Clipboard',
                          'Easily copy card details with one tap',
                        ),
                        _buildFeatureItem(
                          Icons.delete,
                          'Delete Cards',
                          'Remove cards securely and instantly',
                        ),
                        _buildFeatureItem(
                          Icons.edit,
                          'Edit Cards',
                          'Update your card details anytime',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Change Devices (Transfer/Receive)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.devices),
                    title: const Text('Change Devices'),
                    subtitle: const Text('Transfer data between devices'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChangeDevicesScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Copyright
                Text(
                  'Local Cards | 2025 | Sunny Dodti',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
