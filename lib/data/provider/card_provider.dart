import 'package:hive_ce_flutter/adapters.dart';
import '../../data/constants.dart';
import 'package:flutter/material.dart';

import '../../models/card.dart';
import '../../service/card_service.dart';

class CardProvider extends ChangeNotifier {
  // Card detail toggle state
  bool _showNumber = true;
  bool _showCVV = true;
  bool _showExpiry = true;

  bool get showNumber => _showNumber;
  bool get showCVV => _showCVV;
  bool get showExpiry => _showExpiry;

  Future<void> loadCardDetailToggles() async {
    final box = await Hive.openBox(Constants.box);
    _showNumber = box.get(Constants.cardDetailShowNumber, defaultValue: true);
    _showCVV = box.get(Constants.cardDetailShowCVV, defaultValue: true);
    _showExpiry = box.get(Constants.cardDetailShowExpiry, defaultValue: true);
    notifyListeners();
  }

  Future<void> setShowNumber(bool value) async {
    _showNumber = value;
    final box = await Hive.openBox(Constants.box);
    await box.put(Constants.cardDetailShowNumber, value);
    notifyListeners();
  }

  Future<void> setShowCVV(bool value) async {
    _showCVV = value;
    final box = await Hive.openBox(Constants.box);
    await box.put(Constants.cardDetailShowCVV, value);
    notifyListeners();
  }

  Future<void> setShowExpiry(bool value) async {
    _showExpiry = value;
    final box = await Hive.openBox(Constants.box);
    await box.put(Constants.cardDetailShowExpiry, value);
    notifyListeners();
  }

  final CardService _service = CardService.instance();
  List<CardModel> _cards = [];
  bool _loading = false;

  CardProvider() {
    load();
    loadCardDetailToggles();
  }

  List<CardModel> get cards => List.unmodifiable(_cards);
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _cards = await _service.listCards();
    _loading = false;
    notifyListeners();
  }

  Future<void> addCard(CardModel card) async {
    await _service.createCard(card);
    await load();
  }

  Future<void> updateCard(CardModel card) async {
    await _service.updateCard(card);
    await load();
  }

  Future<void> deleteCard(String id) async {
    await _service.deleteCard(id);
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    _cards = [];
    notifyListeners();
  }

  CardModel? getById(String id) {
    try {
      return _cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
