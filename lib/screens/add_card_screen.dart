import 'package:flutter/material.dart';
import '../enums/card_tile_type.dart';
import '../enums/card_type.dart';
import '../models/card.dart';
import '../models/card_network.dart';
import '../widgets/card_tile.dart';
import '../widgets/my_appbar.dart';
import '../widgets/mobile_wrapper.dart';
import 'package:provider/provider.dart';
import '../data/provider/card_provider.dart';

class AddCardScreen extends StatefulWidget {
  final CardModel? editCard;
  const AddCardScreen({super.key, this.editCard});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final issuerController = TextEditingController();
  final cardNameController = TextEditingController();
  final numberController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final cvvController = TextEditingController();
  final holderNameController = TextEditingController();
  CardNetwork? network = CardNetwork.values.first;
  CardType type = CardType.values.first;
  CardColorScheme? colorScheme;
  late final CardViewModel card;

  @override
  void initState() {
    super.initState();
    if (widget.editCard != null) {
      final c = widget.editCard!;
      issuerController.text = c.issuer ?? '';
      cardNameController.text = c.cardName ?? '';
      numberController.text = c.cardNumber;
      monthController.text = c.expiryMonth.toString();
      yearController.text = c.expiryYear.toString();
      cvvController.text = c.cvv;
      holderNameController.text = c.holderName ?? '';
      network = c.network;
      type = c.type;
      colorScheme = c.colorScheme;
      card = CardViewModel.fromModel(c);
    } else {
      card = CardViewModel();
      card.type = type;
      card.network = network;
    }
  }

  @override
  void dispose() {
    issuerController.dispose();
    cardNameController.dispose();
    numberController.dispose();
    monthController.dispose();
    yearController.dispose();
    cvvController.dispose();
    holderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileWrapper(
      child: Scaffold(
        appBar: MyAppbar.build(context, title: 'Add Card', back: true),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: CardTile(
                type: CardTileType.preview,
                card: card.toModel(id: ''),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildCardNameField(),
                        _buildBuildIssuerField(),
                        _buildNetworkField(),
                        _buildCardTypeField(),
                        _buildCardNumberField(),
                        _buildValidityAndCVVFields(),
                        _buildCardHolderField(),
                        const SizedBox(height: 24),
                        _buildSaveButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildValidityAndCVVFields() {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildMonthField()),
        const SizedBox(width: 8),
        Expanded(flex: 1, child: _buildYearField()),
        const SizedBox(width: 8),
        Expanded(flex: 1, child: _buildCVVField()),
      ],
    );
  }

  TextFormField _buildCVVField() {
    return TextFormField(
      controller: cvvController,
      decoration: const InputDecoration(labelText: 'CVV'),
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.creditCardSecurityCode],
      maxLength: 4,
      onChanged: (_) {
        card.cvv = cvvController.text;
        setState(() {});
      },
    );
  }

  TextFormField _buildYearField() {
    return TextFormField(
      controller: yearController,
      decoration: const InputDecoration(labelText: 'YY'),
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.creditCardExpirationYear],
      maxLength: 2,
      onChanged: (v) {
        card.year = int.tryParse(v);
        setState(() {});
      },
    );
  }

  TextFormField _buildMonthField() {
    return TextFormField(
      controller: monthController,
      decoration: const InputDecoration(labelText: 'MM'),
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.creditCardExpirationMonth],
      maxLength: 2,
      onChanged: (_) {
        card.month = int.tryParse(monthController.text);
        setState(() {});
      },
    );
  }

  ElevatedButton _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          final isEdit = widget.editCard != null;
          final id = isEdit
              ? widget.editCard!.id
              : DateTime.now().millisecondsSinceEpoch.toString();
          final cardModel = card.toModel(id: id);
          if (isEdit) {
            await context.read<CardProvider>().updateCard(cardModel);
          } else {
            await context.read<CardProvider>().addCard(cardModel);
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? 'Card updated!' : 'Card saved!')),
          );
          Navigator.of(context).pop();
        }
      },
      child: Text(widget.editCard != null ? 'Update Card' : 'Save Card'),
    );
  }

  DropdownButtonFormField<CardType> _buildCardTypeField() {
    return DropdownButtonFormField<CardType>(
      initialValue: type,
      items: CardType.values
          .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
          .toList(),
      onChanged: (v) {
        setState(() {
          CardType c = CardType.values.firstWhere((e) => e == (v ?? type));
          card.type = c;
          type = c;
        });
      },
      decoration: const InputDecoration(labelText: 'Card Type'),
    );
  }

  TextFormField _buildCardHolderField() {
    return TextFormField(
      controller: holderNameController,
      decoration:
          const InputDecoration(labelText: 'Cardholder Name (optional)'),
      autofillHints: const [AutofillHints.creditCardName],
      onChanged: (_) {
        card.holderName = holderNameController.text;
        setState(() {});
      },
    );
  }

  TextFormField _buildCardNameField() {
    return TextFormField(
      controller: cardNameController,
      decoration: const InputDecoration(labelText: 'Card Name'),
      onChanged: (_) {
        card.cardName = cardNameController.text;
        setState(() {});
      },
    );
  }

  Center _buildCardNumberField() {
    return Center(
      child: TextFormField(
        controller: numberController,
        decoration: const InputDecoration(labelText: 'Card Number'),
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.creditCardNumber],
        onChanged: (_) {
          card.number = numberController.text;
          setState(() {});
        },
        validator: (v) =>
            (v == null || v.trim().length < 12) ? 'Invalid' : null,
      ),
    );
  }

  DropdownButtonFormField<CardNetwork> _buildNetworkField() {
    return DropdownButtonFormField<CardNetwork>(
      initialValue: network,
      items: CardNetwork.values
          .map((n) =>
              DropdownMenuItem(value: n, child: Text(n.name.toUpperCase())))
          .toList(),
      onChanged: (v) {
        CardNetwork c =
            CardNetwork.values.firstWhere((e) => e == (v ?? network));
        card.network = c;
        setState(() => network = c);
      },
      decoration: const InputDecoration(labelText: 'Card Network'),
    );
  }

  TextFormField _buildBuildIssuerField() {
    return TextFormField(
      controller: issuerController,
      decoration: const InputDecoration(labelText: 'Issuer (Bank, etc)'),
      onChanged: (_) {
        card.issuer = issuerController.text;
        setState(() {});
      },
    );
  }
}
