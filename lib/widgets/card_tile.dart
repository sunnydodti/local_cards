import 'package:flutter/material.dart';

import '../enums/card_tile_type.dart';
import '../models/card.dart';
import '../data/ui_constants.dart';
import '../models/card_tile_detail_visibility.dart';
import 'card_display_text.dart';

typedef EditCallback = void Function(CardModel card);
typedef DeleteCallback = void Function(String id);

class CardTile extends StatelessWidget {
  final CardModel card;
  final CardTileType type;
  final EditCallback? onEdit;
  final DeleteCallback? onDelete;
  final CardTileDetailVisibility detailVisibility;

  const CardTile({
    super.key,
    required this.card,
    this.onEdit,
    this.onDelete,
    this.type = CardTileType.masked,
    this.detailVisibility = const CardTileDetailVisibility(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: UIConstants.cardVerticalMargin),
      decoration: _getCardDecoration(theme),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: UIConstants.cardPaddingHorizontal,
            vertical: UIConstants.cardPaddingVertical),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _displayCardNameIssuerNetworkAndType(),
            _displayCardNumber(),
            _displayCardHolderExpiryAndCVV(),
          ],
        ),
      ),
    );
  }

  Row _displayCardHolderExpiryAndCVV() {
    String cardHolderName = _holderDisplayText;
    String expiryText = _getExpiryDisplayText;
    String cvvText = _getCVVDisplayText;

    String? cardHolderSecondary;
    String? expirySecondry;
    String? cvvSecondry;

    if (cardHolderName.isNotEmpty) {
      cardHolderSecondary = 'Card Holder';
    }
    if (expiryText.isNotEmpty) {
      expirySecondry = 'Expiry';
    }
    if (cvvText.isNotEmpty) {
      cvvSecondry = 'CVV';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CardDisplayText(
            primaryText: _holderDisplayText,
            secondaryText: cardHolderSecondary,
            scaleSecondaryText: true),
        if (type == CardTileType.preview || type == CardTileType.detailed)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CardDisplayText(
                    primaryText: expiryText, secondaryText: expirySecondry),
                SizedBox(width: 16),
                CardDisplayText(
                    primaryText: cvvText, secondaryText: cvvSecondry),
              ],
            ),
          ),
      ],
    );
  }

  Padding _displayCardNumber() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Text(
          _cardNumberDisplayText,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _displayCardNameIssuerNetworkAndType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardDisplayText(
            primaryText: _cardNameDisplayText,
            secondaryText: _issuerDisplayText),
        CardDisplayText(
            primaryText: _networkDisplayText,
            secondaryText: _getCardTypeDisplayText,
            alignment: CrossAxisAlignment.end)
      ],
    );
  }

  String get _issuerDisplayText {
    String displayText = '';
    if (card.issuer != null && card.issuer!.isNotEmpty) {
      displayText += card.issuer!;
    }
    if (displayText.isNotEmpty &&
        card.cardName != null &&
        card.cardName!.isNotEmpty) {
      displayText = 'by $displayText';
    }
    return displayText;
  }

  String get _networkDisplayText => _getDisplayText(card.network?.name);
  String get _holderDisplayText => _getDisplayText(card.holderName);
  String get _getCardTypeDisplayText => _getDisplayText(card.type.name);
  String get _getCVVDisplayText => _getConditionalDisplayText(
      card.cvv, (detailVisibility.showCVV || type == CardTileType.preview));

  String get _getExpiryDisplayText => _getConditionalDisplayText(
      card.getExpiryDisplayText,
      (detailVisibility.showExpiry || type == CardTileType.preview));

  String get _cardNumberDisplayText {
    if (type == CardTileType.masked) {
      return card.maskedNumberText;
    }
    if (type != CardTileType.preview && !detailVisibility.showNumber) {
      return card.maskedNumberText;
    }
    return _getConditionalDisplayText(card.cardNumberText,
        type == CardTileType.preview || detailVisibility.showNumber);
  }

  String get _cardNameDisplayText => _getDisplayText(card.cardName);

  String _getDisplayText(String? text, {bool upper = true}) {
    if (text == null) return '';
    if (upper) return text.toUpperCase();
    return text;
  }

  String _getConditionalDisplayText(String text, bool condition) {
    if (condition) return text;

    String maskedText = '';
    for (int i = 0; i < text.length; i++) {
      if (text[i] == ' ') {
        maskedText += ' ';
        continue;
      }
      if (text[i] == '/') {
        maskedText += '/';
        continue;
      }
      maskedText += '•';
    }
    return maskedText;
  }

  BoxDecoration _getCardDecoration(ThemeData theme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(UIConstants.cardRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary
              .withValues(alpha: UIConstants.cardGradientOpacity),
          Color.lerp(theme.colorScheme.primary, Colors.black, 0.25)!
              .withValues(alpha: UIConstants.cardGradientOpacity),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(UIConstants.cardShadowAlpha),
          blurRadius: UIConstants.cardShadowBlur,
          offset: Offset(0, UIConstants.cardShadowOffsetY),
        ),
      ],
    );
  }
}
