import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/constants.dart';

import '../models/card.dart';

/// Simple secure storage backed CRUD service for `CardModel`.
///
/// Storage layout:
/// - A JSON array of ids is stored under key `${Constants.box}:_cards_index_v1`.
/// - Each card is stored under `${Constants.box}:card:{id}` as JSON.
class CardService {
  CardService._(this._storage);

  static final CardService _instance =
      CardService._(const FlutterSecureStorage());

  factory CardService.instance() => _instance;

  final FlutterSecureStorage _storage;

  // Use `Constants.box` as a prefix so keys are namespaced consistently.
  static final String _indexKey = '${Constants.box}:_cards_index_v1';

  String _cardKey(String id) => '${Constants.box}:card:$id';

  Future<List<CardModel>> listCards() async {
    final idx = await _storage.read(key: _indexKey);
    if (idx == null || idx.isEmpty) return [];
    final List ids = json.decode(idx) as List;
    final List<CardModel> out = [];
    for (final dynamic id in ids) {
      try {
        final value = await _storage.read(key: _cardKey(id as String));
        if (value == null) continue;
        out.add(CardModel.fromJson(value));
      } catch (_) {
        // Skip malformed entries
        continue;
      }
    }
    // sort by createdAt descending
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  Future<CardModel?> getCard(String id) async {
    final value = await _storage.read(key: _cardKey(id));
    if (value == null) return null;
    return CardModel.fromJson(value);
  }

  Future<String> _generateId() async {
    final r = Random.secure().nextInt(1 << 31);
    return '${DateTime.now().millisecondsSinceEpoch}-$r';
  }

  Future<void> createCard(CardModel card) async {
    final id = card.id.isNotEmpty ? card.id : await _generateId();
    final now = DateTime.now();
    final toStore = CardModel(
      id: id,
      holderName: card.holderName,
      cardNumber: card.cardNumber,
      expiryMonth: card.expiryMonth,
      expiryYear: card.expiryYear,
      issuer: card.issuer,
      network: card.network,
      cardName: card.cardName,
      cvv: card.cvv,
      type: card.type,
      colorScheme: card.colorScheme,
      createdAt: card.createdAt,
      updatedAt: now,
    );

    await _storage.write(key: _cardKey(id), value: toStore.toJson());

    final idx = await _storage.read(key: _indexKey);
    List ids = idx == null || idx.isEmpty ? [] : json.decode(idx) as List;
    if (!ids.contains(id)) {
      ids.add(id);
      await _storage.write(key: _indexKey, value: json.encode(ids));
    }
  }

  Future<void> updateCard(CardModel card) async {
    final existing = await getCard(card.id);
    if (existing == null) throw StateError('Card not found: ${card.id}');
    final updated = card.copyWith(updatedAt: DateTime.now());
    await _storage.write(key: _cardKey(card.id), value: updated.toJson());
  }

  Future<void> deleteCard(String id) async {
    await _storage.delete(key: _cardKey(id));
    final idx = await _storage.read(key: _indexKey);
    if (idx == null || idx.isEmpty) return;
    final List ids = json.decode(idx) as List;
    ids.remove(id);
    await _storage.write(key: _indexKey, value: json.encode(ids));
  }

  Future<void> clearAll() async {
    // delete each card entry, then index
    final idx = await _storage.read(key: _indexKey);
    if (idx != null && idx.isNotEmpty) {
      final List ids = json.decode(idx) as List;
      for (final dynamic id in ids) {
        await _storage.delete(key: _cardKey(id as String));
      }
    }
    await _storage.delete(key: _indexKey);
  }
}
