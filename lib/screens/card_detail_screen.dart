import 'add_card_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/my_button.dart';

import '../services/clipboard_service.dart';
import 'package:provider/provider.dart';

import '../data/provider/card_provider.dart';
import '../models/card_tile_detail_visibility.dart';
import '../widgets/card_tile.dart';
import '../enums/card_tile_type.dart';
import '../widgets/my_appbar.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;
  const CardDetailScreen({super.key, required this.cardId});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  @override
  void initState() {
    super.initState();
    // No local state, provider handles toggles
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.build(context, title: 'Card Details', back: true),
      body: _displayBody(context),
    );
  }

  Widget _displayBody(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, provider, _) {
        final card = provider.getById(widget.cardId);
        if (card == null) {
          return const Center(child: Text('Card not found.'));
        }
        return ListView(
          padding: const EdgeInsets.all(12.0),
          children: [
            CardTile(
              card: card,
              type: CardTileType.detailed,
              detailVisibility: CardTileDetailVisibility(
                showNumber: provider.showNumber,
                showCVV: provider.showCVV,
                showExpiry: provider.showExpiry,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _copyButton(context, label: 'Number', value: card.cardNumber),
                _copyButton(context,
                    label: 'Expiry', value: card.getExpiryDisplayText),
                _copyButton(context, label: 'CVV', value: card.cvv),
              ],
            ),
            const SizedBox(height: 16),
            _toggleRow(context),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddCardScreen(editCard: card),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: MyButton(
                    onPressed: _handleDelete,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDelete() async {
    final card = context.read<CardProvider>().getById(widget.cardId);
    if (card == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<CardProvider>().deleteCard(card.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Widget _toggleRow(BuildContext context) {
    final provider = Provider.of<CardProvider>(context, listen: false);
    return Column(
      children: [
        SwitchListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: const Text('Show Number'),
          value: provider.showNumber,
          onChanged: (v) => provider.setShowNumber(v),
        ),
        SwitchListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: const Text('Show Expiry'),
          value: provider.showExpiry,
          onChanged: (v) => provider.setShowExpiry(v),
        ),
        SwitchListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: const Text('Show CVV'),
          value: provider.showCVV,
          onChanged: (v) => provider.setShowCVV(v),
        ),
      ],
    );
  }

  Widget _copyButton(BuildContext context,
      {required String label, required String value}) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.copy, size: 18),
      label: Text(label),
      onPressed: value.isEmpty
          ? null
          : () async {
              await ClipboardService.copySensitive(value);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label copied! Clipboard will auto-clear.'), duration: const Duration(seconds: 2)),
                );
              }
            },
    );
  }
}
