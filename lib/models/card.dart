import 'dart:convert';

import '../enums/card_type.dart';
import 'card_network.dart';

class CardColorScheme {
  final int bgColor;
  final int textColor;
  const CardColorScheme({required this.bgColor, required this.textColor});

  Map<String, dynamic> toMap() => {
        'bgColor': bgColor,
        'textColor': textColor,
      };
  factory CardColorScheme.fromMap(Map<String, dynamic> map) => CardColorScheme(
        bgColor: map['bgColor'] as int,
        textColor: map['textColor'] as int,
      );
}

extension CardTypeX on CardType {
  String get name {
    switch (this) {
      case CardType.credit:
        return 'credit';
      case CardType.debit:
        return 'debit';
      case CardType.other:
        return 'other';
    }
  }

  static CardType fromString(String? s) {
    if (s == null) return CardType.other;
    switch (s) {
      case 'credit':
        return CardType.credit;
      case 'debit':
        return CardType.debit;
      default:
        return CardType.other;
    }
  }
}

class CardModel {
  final String id;
  final String? issuer; // Bank or issuer (optional)
  final CardNetwork? network; // Visa, Mastercard, etc (optional)
  final String? cardName; // Black, Privilege, etc
  final String cardNumber;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;
  final String? holderName; // optional
  final CardType type;
  final CardColorScheme? colorScheme;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardModel({
    required this.id,
    this.issuer,
    this.network,
    this.cardName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.holderName,
    this.type = CardType.credit,
    this.colorScheme,
    // removed duplicate cvv
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Returns a masked card number suitable for UI (keeps last 4 digits).

  String get maskedNumberText {
    String number = cardNumber;
    final last =
        number.length >= 4 ? number.substring(number.length - 4) : number;
    final maskedLength = number.length - 4;
    final buffer = StringBuffer();
    for (int i = 0; i < maskedLength; i++) {
      buffer.write('•');
      if ((i + 1) % 4 == 0 && i != maskedLength - 1) {
        buffer.write(' ');
      }
    }
    final masked = buffer.toString();
    return '$masked $last';
  }

  String get cardNumberText {
    String number = cardNumber;
    final buffer = StringBuffer();
    for (int i = 0; i < number.length; i++) {
      buffer.write(number[i]);
      if ((i + 1) % 4 == 0 && i != number.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  String get getExpiryDisplayText {
    String seperator = '';
    String month = '';
    String year = '';

    if (expiryMonth != 0 && expiryYear != 0) seperator = '/';
    if (expiryMonth != 0) month = '$expiryMonth';
    if (expiryYear != 0) year = '$expiryYear';
    return '$month$seperator$year';
  }

  CardModel copyWith({
    String? issuer,
    CardNetwork? network,
    String? cardName,
    String? cardNumber,
    int? expiryMonth,
    int? expiryYear,
    String? cvv,
    String? holderName,
    CardType? type,
    CardColorScheme? colorScheme,
    DateTime? updatedAt,
  }) {
    return CardModel(
      id: id,
      issuer: issuer ?? this.issuer,
      network: network ?? this.network,
      cardName: cardName ?? this.cardName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      holderName: holderName ?? this.holderName,
      type: type ?? this.type,
      colorScheme: colorScheme ?? this.colorScheme,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'issuer': issuer,
      'network': network?.name,
      'cardName': cardName,
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'holderName': holderName,
      'type': type.name,
      'colorScheme': colorScheme?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as String,
      issuer: map['issuer'] as String?,
      network: map['network'] != null
          ? CardNetwork.values.firstWhere((e) => e.name == map['network'])
          : null,
      cardName: map['cardName'] as String?,
      cardNumber: map['cardNumber'] as String,
      expiryMonth: (map['expiryMonth'] as num).toInt(),
      expiryYear: (map['expiryYear'] as num).toInt(),
      cvv: map['cvv'] as String,
      holderName: map['holderName'] as String?,
      type: CardTypeX.fromString(map['type'] as String?),
      colorScheme: map['colorScheme'] != null
          ? CardColorScheme.fromMap(
              Map<String, dynamic>.from(map['colorScheme']))
          : null,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CardModel.fromJson(String source) =>
      CardModel.fromMap(json.decode(source));
}

// make a card view model for UI purposes where I can edit fields from user input
class CardViewModel {
  String? issuer;
  CardNetwork? network;
  String? cardName;
  String? number;
  int? month;
  int? year;
  String cvv = '';
  String? holderName;
  CardType type = CardType.credit;
  CardColorScheme? colorScheme;

  CardViewModel();

  CardViewModel.fromModel(CardModel model) {
    issuer = model.issuer;
    network = model.network;
    cardName = model.cardName;
    number = model.cardNumber;
    month = model.expiryMonth;
    year = model.expiryYear;
    cvv = model.cvv;
    holderName = model.holderName;
    type = model.type;
    colorScheme = model.colorScheme;
  }
  CardModel toModel({required String id}) {
    return CardModel(
      id: id,
      issuer: issuer,
      network: network,
      cardName: cardName,
      cardNumber: number ?? '',
      expiryMonth: month ?? 0,
      expiryYear: year ?? 0,
      cvv: cvv,
      holderName: holderName ?? '',
      type: type,
      colorScheme: colorScheme,
    );
  }
}
