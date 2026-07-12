import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/provider/card_provider.dart';
import '../enums/card_tile_type.dart';
import '../widgets/my_appbar.dart';
import '../widgets/mobile_wrapper.dart';
import '../widgets/card_tile.dart';
import 'add_card_screen.dart';

import 'card_detail_screen.dart';
import 'settings_screen.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(
          context,
          leading: _buildSettingsButton(context),
        ),
        body: SafeArea(
          child: Consumer<CardProvider>(builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final cards = provider.cards;
            if (cards.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('No cards yet',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text('Tap + to add your first card',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => provider.load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CardDetailScreen(cardId: cards[i].id),
                      ),
                    );
                  },
                  child: CardTile(
                    type: CardTileType.masked,
                    card: cards[i],
                    onDelete: (id) async {
                      await provider.deleteCard(id);
                    },
                  ),
                ),
              ),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddCardScreen()),
            );
            // reload
            if (!context.mounted) return;
            context.read<CardProvider>().load();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  IconButton _buildSettingsButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
      },
      icon: const Icon(Icons.settings_outlined),
    );
  }
}
